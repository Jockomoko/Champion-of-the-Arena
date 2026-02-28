extends Node2D
const CHAMPION_SCENE = preload("uid://d2xtwn0w40ncd")

@onready var ability_sheet: Control = $Control/AbilitySheet
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var player_spawns: Array = $MultiplayerSpawner/Spawn_points/Own_Spawn_points.get_children()
@onready var enemy_spawns: Array = $MultiplayerSpawner/Spawn_points/Enemy_Spawn_points.get_children()



var collected_teams := {}

func _ready():
	if Steam.getLobbyOwner(Globals.LOBBY_ID) == Globals.STEAM_ID:
		request_team_data.rpc()

@rpc("authority", "call_local", "reliable")
func request_team_data() -> void:
	var team_data = Globals.MY_PLAYERCONTROLLER.get_champions_team_data()
	if Steam.getLobbyOwner(Globals.LOBBY_ID) == Globals.STEAM_ID:
		submit_team_data(Globals.STEAM_ID, team_data)
	else:
		submit_team_data.rpc_id(1, Globals.STEAM_ID, team_data)

@rpc("any_peer", "reliable")
func submit_team_data(steam_id: int, team_data: Array) -> void:
	print("submit_team_data received! steam_id: ", steam_id)
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID:
		return
	collected_teams[steam_id] = team_data
	print("Got team from:", steam_id)
	if collected_teams.size() == Globals.LOBBY_MEMBERS.size():
		start_arena()

# =====================================================
# STEP 3 — Spawn when all data is collected
# =====================================================
func start_arena():
	var steam_ids = collected_teams.keys()
	steam_ids.shuffle()
	spawn_team(collected_teams[steam_ids[0]], player_spawns, true)
	#spawn_team(collected_teams[steam_ids[1]], enemy_spawns, false)
	

func spawn_team(team_data: Array, spawns: Array, own_champions: bool):
	if spawns.size() < team_data.size():
		push_error("Not enough spawn points!")
		return
	for i in team_data.size():
		var champion = CHAMPION_SCENE.instantiate()
		
		# Match the keys from Champion.to_dict()
		champion.name = team_data[i]["name"]
		for stat_name in team_data[i]["stats"].keys():
			champion.set_stat(stat_name, team_data[i]["stats"][stat_name])
		add_child(champion)
		champion.global_position = spawns[i].global_position
		
		if own_champions:
			ability_sheet.add_player_bar(champion.get_max_health(), champion.get_max_mana())
