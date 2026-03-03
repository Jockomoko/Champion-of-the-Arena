extends Node2D

const CHAMPION_SCENE = preload("uid://d2xtwn0w40ncd")
@onready var ability_sheet: Control = $Control/AbilitySheet
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var player_spawns: Array = $MultiplayerSpawner/Spawn_points/Own_Spawn_points.get_children()
@onready var enemy_spawns: Array = $MultiplayerSpawner/Spawn_points/Enemy_Spawn_points.get_children()

var collected_teams := {}
var all_champions: Array[Champion] = []
var player_champions: Array[Champion] = []

func _ready():
	RoundController.player_waiting.connect(_on_player_waiting)
	CombatController.turn_started.connect(_on_turn_started)
	CombatController.turn_ended.connect(_on_turn_ended)
	CombatController.combat_ended.connect(_on_combat_ended)

	if RoundController.is_waiting_this_round():
		_show_waiting_screen()
		return

	if Steam.getLobbyOwner(Globals.LOBBY_ID) == Globals.STEAM_ID:
		request_team_data.rpc()

@rpc("authority", "call_local", "reliable")
func request_team_data() -> void:
	var team_data = Globals.MY_PLAYERCONTROLLER.get_champions_team_data()

	if Globals.STEAM_ID == Steam.getLobbyOwner(Globals.LOBBY_ID):
		submit_team_data(Globals.STEAM_ID, team_data)
	else:
		# Use get_server_id() not Steam ID, because create_client maps host as peer 1
		submit_team_data.rpc_id(multiplayer.get_server_id(), Globals.STEAM_ID, team_data)

@rpc("any_peer", "reliable")
func submit_team_data(steam_id: int, team_data: Array) -> void:
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID:
		return
	if not RoundController.current_matches.has(steam_id):
		return
	
	collected_teams[steam_id] = team_data
	print("Got team from:", steam_id)
	
	var expected = RoundController.current_matches.size()
	if collected_teams.size() == expected:
		_send_match_to_pairs()  # ← replaced _broadcast_spawn.rpc(collected_teams)

func _send_match_to_pairs() -> void:
	var sent_pairs = []
	for steam_id in RoundController.current_matches.keys():
		if steam_id in sent_pairs:
			continue
		var opponent_id = RoundController.current_matches[steam_id]
		var match_teams = {}
		match_teams[steam_id] = collected_teams[steam_id]
		match_teams[opponent_id] = collected_teams[opponent_id]
		
		# Send only to the two players in this match
		_broadcast_spawn.rpc_id(steam_id, match_teams)
		_broadcast_spawn.rpc_id(opponent_id, match_teams)
		
		sent_pairs.append(steam_id)
		sent_pairs.append(opponent_id)

@rpc("authority", "call_local", "reliable")
func _broadcast_spawn(teams: Dictionary) -> void:
	var my_opponent = RoundController.get_my_opponent()
	
	if teams.has(Globals.STEAM_ID):
		spawn_team(teams[Globals.STEAM_ID], player_spawns, true, Globals.STEAM_ID)
	
	if my_opponent != -1 and teams.has(my_opponent):
		spawn_team(teams[my_opponent], enemy_spawns, false, my_opponent)
	
	if Steam.getLobbyOwner(Globals.LOBBY_ID) == Globals.STEAM_ID:
		CombatController.start_combat(all_champions)

func spawn_team(team_data: Array, spawns: Array, own_champions: bool, owner_steam_id: int) -> void:
	if spawns.size() < team_data.size():
		push_error("Not enough spawn points!")
		return
	for i in team_data.size():
		var champion = CHAMPION_SCENE.instantiate()
		champion.name = team_data[i]["name"]
		for stat_name in team_data[i]["stats"].keys():
			champion.set_stat(stat_name, team_data[i]["stats"][stat_name])
		add_child(champion)
		champion.global_position = spawns[i].global_position
		all_champions.append(champion)
		CombatController.register_owner(champion, owner_steam_id)
		if own_champions:
			player_champions.append(champion)
			ability_sheet.add_player_bar(champion.get_max_health(), champion.get_max_mana())

func _on_turn_started(champion: Champion) -> void:
	print("It's %s's turn!" % champion.champion_name)
	champion.modulate = Color.YELLOW
	if CombatController.is_my_turn():
		var abilities = champion.ability_component.get_available_abilities()
		ability_sheet.show_ability_menu(abilities)
	else:
		ability_sheet.show_waiting(champion.champion_name)

func _on_turn_ended(champion: Champion) -> void:
	champion.modulate = Color.WHITE
	ability_sheet.hide_ability_menu()

func _on_combat_ended(winner: Champion) -> void:
	print("Combat ended! Winner: ", winner.champion_name)
	
	var winner_id: int
	var loser_id: int
	if player_champions.has(winner):
		winner_id = Globals.STEAM_ID
		loser_id = RoundController.get_my_opponent()
	else:
		winner_id = RoundController.get_my_opponent()
		loser_id = Globals.STEAM_ID
	
	if winner_id == Globals.STEAM_ID:
		Globals.MY_PLAYERCONTROLLER.win_match()
	else:
		Globals.MY_PLAYERCONTROLLER.lose_match()
	
	# Only host reports to RoundController
	if Steam.getLobbyOwner(Globals.LOBBY_ID) == Globals.STEAM_ID:
		RoundController.report_match_result(winner_id, loser_id)

func _on_player_waiting(steam_id: int) -> void:
	if steam_id == Globals.STEAM_ID:
		_show_waiting_screen()

func _show_waiting_screen() -> void:
	ability_sheet.hide()
	print("Waiting for other players to finish their match...")
