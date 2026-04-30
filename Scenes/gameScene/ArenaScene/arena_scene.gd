extends Node2D

# ── Preloads ───────────────────────────────────────────────────────────────────
const CHAMPION_SCENE = preload("uid://d2xtwn0w40ncd")

# ── Node refs ──────────────────────────────────────────────────────────────────
@onready var ability_sheet: Control = $Control/AbilitySheet
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var player_spawns: Array = $MultiplayerSpawner/Spawn_points/Own_Spawn_points.get_children()
@onready var enemy_spawns: Array = $MultiplayerSpawner/Spawn_points/Enemy_Spawn_points.get_children()

# ── State ──────────────────────────────────────────────────────────────────────
var current_champion: Champion
var pending_ability: String = ""
var collected_teams: Dictionary = {}
var all_champions: Array[Champion] = []
var player_champions: Array[Champion] = []
var ready_players: int = 0

# ── Lifecycle ──────────────────────────────────────────────────────────────────
func _ready() -> void:
	_reset_state()
	_connect_signals()

	if RoundController.is_waiting_this_round():
		_show_waiting_screen()
		return

	_submit_my_team()

func _reset_state() -> void:
	collected_teams.clear()
	all_champions.clear()
	player_champions.clear()
	ready_players = 0
	CombatController.champion_owners.clear()

func _connect_signals() -> void:
	RoundController.player_waiting.connect(_on_player_waiting)
	CombatController.turn_started.connect(_on_turn_started)
	CombatController.turn_ended.connect(_on_turn_ended)
	CombatController.combat_ended.connect(_on_combat_ended)
	ability_sheet.ability_selected.connect(_on_ability_selected)

func _submit_my_team() -> void:
	var team_data = Globals.MY_PLAYERCONTROLLER.get_champions_team_data()
	print("Submitting my team: ", Globals.STEAM_ID)
	if Globals.is_host:
		submit_team_data(Globals.STEAM_ID, team_data)
	else:
		submit_team_data.rpc_id(1, Globals.STEAM_ID, team_data)

# ── Network: team collection ───────────────────────────────────────────────────
@rpc("any_peer", "reliable")
func submit_team_data(steam_id: int, team_data: Array) -> void:
	if not Globals.is_host:
		return
	if not RoundController.current_matches.has(steam_id):
		return

	collected_teams[steam_id] = team_data
	print("Got team from: ", steam_id)

	if collected_teams.size() == RoundController.current_matches.size():
		_send_match_to_pairs()

func _send_match_to_pairs() -> void:
	var sent_pairs: Array = []
	for steam_id in RoundController.current_matches.keys():
		if steam_id in sent_pairs:
			continue
		var opponent_id = RoundController.current_matches[steam_id]
		var match_teams = {
			steam_id: collected_teams[steam_id],
			opponent_id: collected_teams[opponent_id],
		}
		_send_spawn_to_peer(steam_id, match_teams)
		_send_spawn_to_peer(opponent_id, match_teams)
		sent_pairs.append(steam_id)
		sent_pairs.append(opponent_id)

func _send_spawn_to_peer(steam_id: int, match_teams: Dictionary) -> void:
	var peer_id = Globals.steam_to_peer.get(steam_id, -1)
	if peer_id == 1:
		_broadcast_spawn(match_teams)
	elif peer_id != -1:
		_broadcast_spawn.rpc_id(peer_id, match_teams)

# ── Network: spawning ──────────────────────────────────────────────────────────
@rpc("any_peer", "reliable")
func _broadcast_spawn(teams: Dictionary) -> void:
	var opponent_id = RoundController.get_my_opponent()

	if teams.has(Globals.STEAM_ID):
		spawn_team(teams[Globals.STEAM_ID], player_spawns, true, Globals.STEAM_ID)
	if opponent_id != -1 and teams.has(opponent_id):
		spawn_team(teams[opponent_id], enemy_spawns, false, opponent_id)

	CombatController.start_combat(all_champions)

	if Globals.is_host:
		_confirm_ready()
	else:
		_confirm_ready.rpc_id(1)

@rpc("any_peer", "reliable")
func _confirm_ready() -> void:
	if not Globals.is_host:
		return
	ready_players += 1
	print("Ready: %d / 2" % ready_players)
	if ready_players >= 2:
		CombatController.broadcast_first_turn()

func spawn_team(team_data: Array, spawns: Array, own_team: bool, owner_steam_id: int) -> void:
	if spawns.size() < team_data.size():
		push_error("Not enough spawn points for team!")
		return
	print("spawn_team owner=%d own=%s spawns=%d team=%d" % [owner_steam_id, own_team, spawns.size(), team_data.size()])
	for i in team_data.size():
		var champion: Champion = CHAMPION_SCENE.instantiate()
		champion.champion_name = team_data[i]["name"]
		champion.combat_id = "%d_%d" % [owner_steam_id, i]
		champion.name = champion.combat_id
		for stat_name in team_data[i]["stats"]:
			champion.set_stat(stat_name, team_data[i]["stats"][stat_name])

		CombatController.register_owner(champion, owner_steam_id)
		var spawn_pos: Vector2 = spawns[i].position
		champion.home_position = spawn_pos
		add_child(champion)
		champion.position = spawn_pos
		champion.apply_appearance(team_data[i]["appearance"])
		all_champions.append(champion)
		champion.champion_clicked.connect(_on_champion_clicked)

		if own_team:
			player_champions.append(champion)
			ability_sheet.add_player_bar(champion)
		else:
			#Flip champions for opponents
			champion.scale.x *= -1

# ── Combat events ──────────────────────────────────────────────────────────────
func _on_turn_started(champion: Champion) -> void:
	print("It's %s's turn!" % champion.champion_name)
	current_champion = champion
	champion.start_turn()
	if CombatController.is_my_turn():
		ability_sheet.show_ability_menu(champion.abilities.get_available_abilities())
	#else:
		#ability_sheet.show_waiting(champion.champion_name)

func _on_turn_ended(champion: Champion) -> void:
	champion.end_turn()
	ability_sheet.hide_ability_menu()

func _on_combat_ended(winner: Champion) -> void:
	if winner == null:
		push_error("Combat ended with no winner")
		return
	print("Combat ended! Winner: ", winner.champion_name)
	var i_won = player_champions.has(winner)
	var winner_id = Globals.STEAM_ID if i_won else RoundController.get_my_opponent()
	var loser_id  = RoundController.get_my_opponent() if i_won else Globals.STEAM_ID

	if Globals.is_host:
		RoundController.report_match_result(winner_id, loser_id)

	_show_result_screen(i_won)

# ── UI ─────────────────────────────────────────────────────────────────────────
func _on_ability_selected(ability_name: String) -> void:
	# Clear any clickable state left over from a previously selected ability
	for c in all_champions:
		c.set_clickable(false)
	pending_ability = ability_name
	print(current_champion.champion_name + " is casting " + pending_ability)
	var ability = AbilitiesDataBase.get_ability(ability_name)
	if ability:
		var targets = ability.get_valid_targets(current_champion, player_champions, all_champions)
		if targets.size() == 1 and targets[0] == current_champion:
			_on_champion_clicked(current_champion)
		else:
			for champion in targets:
				champion.set_clickable(true)

func _on_champion_clicked(champion: Champion) -> void:
	if pending_ability == "":
		return
	for c in all_champions:
		c.set_clickable(false)

	var ability = AbilitiesDataBase.get_ability(pending_ability)
	var ability_id = pending_ability
	pending_ability = ""
	# Capture attacker NOW before current_champion is overwritten by the next turn.
	var attacker = current_champion

	if not Globals.is_host:
		ability_sheet.hide_ability_menu()

	# Tell all other peers to run the same ability (animations + effects).
	_broadcast_ability.rpc(attacker.combat_id, champion.combat_id, ability_id)

	# Run locally.
	await ability.apply(attacker, champion)

	# Host advances the turn after its own apply() finishes.
	if Globals.is_host:
		CombatController.request_turn_end(attacker.combat_id)

# Received by all OTHER peers — they run apply() independently (animations + effects).
@rpc("any_peer", "reliable")
func _broadcast_ability(attacker_id: String, target_id: String, ability_id: String) -> void:
	var attacker = _find_champion(attacker_id)
	var target   = _find_champion(target_id)
	var ability  = AbilitiesDataBase.get_ability(ability_id)
	if not attacker or not target or not ability:
		return
	await ability.apply(attacker, target)
	if Globals.is_host:
		CombatController.request_turn_end(attacker_id)

func _find_champion(id: String) -> Champion:
	for c in all_champions:
		if c.combat_id == id:
			return c
	return null

func _on_player_waiting(steam_id: int) -> void:
	if steam_id == Globals.STEAM_ID:
		_show_waiting_screen()


func _show_waiting_screen() -> void:
	ability_sheet.hide()
	print("Waiting for other players to finish their match...")

func _show_result_screen(did_win: bool) -> void:
	ability_sheet.hide()
	var label = Label.new()
	label.text = "You won! Waiting for other matches..." if did_win else "You lost! Waiting for other matches..."
	label.set_anchors_preset(Control.PRESET_CENTER)
	$Control.add_child(label)
