extends Node2D

# Champion scene
const CHAMPION_SCENE = preload("uid://d2xtwn0w40ncd")

@onready var multiplayer_spawner : MultiplayerSpawner = $MultiplayerSpawner
@onready var player_spawns : Array = $MultiplayerSpawner/Spawn_points/Own_Spawn_points.get_children()
@onready var enemy_spawns  : Array = $MultiplayerSpawner/Spawn_points/Enemy_Spawn_points.get_children()


func _ready():
	# Only host/server spawns players
	if multiplayer.is_server():
		start_arena()


# =====================================================
# START MATCH
# =====================================================
func start_arena():
	var players := GameController.lobby_players.values()

	if players.size() < 2:
		push_error("Not enough players in lobby!")
		return

	# Shuffle to pick random players
	players.shuffle()

	var player_a = players[0]["controller"]
	var player_b = players[1]["controller"]

	# Spawn each player's champions
	spawn_team(player_a, player_spawns)
	spawn_team(player_b, enemy_spawns)


# =====================================================
# SPAWN PLAYER TEAM
# =====================================================
func spawn_team(controller: PlayerController, spawns: Array):
	var team_size = controller.team.champions.size()

	if spawns.size() < team_size:
		push_error("Not enough spawn points for player's team!")
		return

	for i in range(team_size):
		var champ_data = controller.team.champions[i]
		var champ_instance = CHAMPION_SCENE.instantiate()

		# Position and multiplayer authority
		champ_instance.global_position = spawns[i].global_position
		champ_instance.set_multiplayer_authority(controller.player_id)

		# Assign champion data (stats, abilities, etc.)
		champ_instance.team = champ_data.duplicate()
		
		multiplayer_spawner.add_child(champ_instance)
