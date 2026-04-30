extends Node
signal round_started(matches: Array)
signal player_waiting(steam_id: int)
signal all_matches_done
signal solo_detected
signal player_eliminated(steam_id: int)
signal tournament_winner(steam_id: int)

var active_players: Array = []
var current_matches: Dictionary = {}
var finished_matches: Array = []
var waiting_player: int = -1
var reported_players: Array = []

func start_round(steam_ids: Array) -> void:
	active_players = steam_ids.duplicate()
	reported_players.clear()

	if active_players.size() == 1:
		_broadcast_solo_check.rpc()
		return
	active_players.shuffle()
	finished_matches.clear()
	current_matches.clear()
	waiting_player = -1
	
	var matches = []
	
	# Pair players up
	for i in range(0, active_players.size() - 1, 2):
		var p1 = active_players[i]
		var p2 = active_players[i + 1]
		current_matches[p1] = p2
		current_matches[p2] = p1
		matches.append({"player1": p1, "player2": p2})
	
	# Odd player out
	if active_players.size() % 2 == 1:
		waiting_player = active_players[-1]
		player_waiting.emit(waiting_player)
	
	_broadcast_round_started.rpc(matches, current_matches, waiting_player)

@rpc("authority", "call_local", "reliable")
func _broadcast_solo_check() -> void:
	solo_detected.emit()

@rpc("authority", "call_local", "reliable")
func _broadcast_round_started(matches: Array, matches_dict: Dictionary, bye_player: int) -> void:
	current_matches = matches_dict
	waiting_player = bye_player
	round_started.emit(matches)

func report_match_result(winner_id: int, loser_id: int) -> void:
	# Only host should call this
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID:
		return
	# Prevent double-reporting the same match (e.g. from disconnect + normal finish)
	if loser_id in reported_players or winner_id in reported_players:
		return
	reported_players.append(winner_id)
	reported_players.append(loser_id)

	finished_matches.append({"winner": winner_id, "loser": loser_id})
	_broadcast_match_result.rpc(winner_id, loser_id)
	
	# Check if all matches are done
	var expected_matches = current_matches.size() / 2
	if finished_matches.size() >= expected_matches:
		_on_all_matches_done()

@rpc("authority", "call_local", "reliable")
func _broadcast_match_result(winner_id: int, loser_id: int) -> void:
	print("Match done — winner: %d, loser: %d" % [winner_id, loser_id])
	var my_id = Globals.STEAM_ID
	if my_id == winner_id:
		Globals.MY_PLAYERCONTROLLER.win_match()
	elif my_id == loser_id:
		Globals.MY_PLAYERCONTROLLER.lose_match()

func _on_all_matches_done() -> void:
	# Wait briefly so any in-flight elimination RPCs can arrive before we
	# decide who plays next round.
	await get_tree().create_timer(0.3).timeout

	# All non-eliminated players (winners AND losers who still have glory)
	# continue to the next round.
	var next_players: Array = active_players.duplicate()

	if next_players.size() == 1:
		# Tournament over — last player standing wins.
		_broadcast_tournament_end.rpc(next_players[0])
	elif next_players.is_empty():
		# Everyone was eliminated simultaneously.
		_broadcast_tournament_end.rpc(-1)
	else:
		start_round(next_players)
		_broadcast_all_matches_done.rpc()

@rpc("authority", "call_local", "reliable")
func _broadcast_all_matches_done() -> void:
	all_matches_done.emit()

@rpc("authority", "call_local", "reliable")
func _broadcast_tournament_end(winner_id: int) -> void:
	print("Tournament winner: %d" % winner_id)
	all_matches_done.emit()

# Called on host only — removes a player and checks if the game is over
func eliminate_player(steam_id: int) -> void:
	if not Globals.is_host:
		return
	active_players.erase(steam_id)
	# Remove from current_matches so a later disconnect doesn't re-trigger reporting.
	var opponent_id: int = current_matches.get(steam_id, -1)
	if opponent_id != -1:
		current_matches.erase(steam_id)
		current_matches.erase(opponent_id)
	_broadcast_player_eliminated.rpc(steam_id)
	if active_players.size() == 1:
		_broadcast_tournament_winner.rpc(active_players[0])
	elif active_players.is_empty():
		# Edge case: last two players lost simultaneously
		_broadcast_tournament_winner.rpc(-1)

@rpc("authority", "call_local", "reliable")
func _broadcast_player_eliminated(steam_id: int) -> void:
	player_eliminated.emit(steam_id)

@rpc("authority", "call_local", "reliable")
func _broadcast_tournament_winner(steam_id: int) -> void:
	tournament_winner.emit(steam_id)

func get_my_opponent() -> int:
	return current_matches.get(Globals.STEAM_ID, -1)

func is_waiting_this_round() -> bool:
	return waiting_player == Globals.STEAM_ID
