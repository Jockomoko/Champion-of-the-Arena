extends Node
signal round_started(matches: Array)
signal player_waiting(steam_id: int)
signal all_matches_done
signal solo_detected

var active_players: Array = []
var current_matches: Dictionary = {}
var finished_matches: Array = []
var waiting_player: int = -1

func start_round(steam_ids: Array) -> void:
	active_players = steam_ids.duplicate()
	
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
	
	finished_matches.append({"winner": winner_id, "loser": loser_id})
	_broadcast_match_result.rpc(winner_id, loser_id)
	
	# Check if all matches are done
	var expected_matches = current_matches.size() / 2
	if finished_matches.size() >= expected_matches:
		_on_all_matches_done()

@rpc("authority", "call_local", "reliable")
func _broadcast_match_result(winner_id: int, loser_id: int) -> void:
	print("Match done — winner: %d, loser: %d" % [winner_id, loser_id])

func _on_all_matches_done() -> void:
	# Build next round from winners + bye player
	var next_players: Array[int] = []
	for match_result in finished_matches:
		next_players.append(match_result["winner"])
	if waiting_player != -1:
		next_players.append(waiting_player)
	
	if next_players.size() == 1:
		# Tournament over
		_broadcast_tournament_end.rpc(next_players[0])
	else:
		# More rounds to play
		_broadcast_all_matches_done.rpc()

@rpc("authority", "call_local", "reliable")
func _broadcast_all_matches_done() -> void:
	all_matches_done.emit()

@rpc("authority", "call_local", "reliable")
func _broadcast_tournament_end(winner_id: int) -> void:
	print("Tournament winner: %d" % winner_id)
	all_matches_done.emit()

func get_my_opponent() -> int:
	return current_matches.get(Globals.STEAM_ID, -1)

func is_waiting_this_round() -> bool:
	return waiting_player == Globals.STEAM_ID
