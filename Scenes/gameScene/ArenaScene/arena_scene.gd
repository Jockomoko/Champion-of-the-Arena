extends Node2D

# Champion scene
const CHAMPION_SCENE = preload("uid://d2xtwn0w40ncd")

@onready var multiplayer_spawner : MultiplayerSpawner = $MultiplayerSpawner

@onready var player_spawns : Array = $SpawnPoints/PlayerSpawns.get_children()
@onready var enemy_spawns  : Array = $SpawnPoints/EnemySpawns.get_children()


func _ready():

	# Only host/server spawns players
	if multiplayer.is_server():
		start_arena()


# =====================================================
# START MATCH
# =====================================================

func start_arena():

	# Example: get players from your GameController
	var players : Array = GameController.players

	# Safety check
	if players.size() < 2:
		print("Not enough players!")
		return

	# Pick two players randomly
	players.shuffle()

	var player_a = players[0]
	var player_b = players[1]

	spawn_match(player_a.peer_id, player_b.peer_id)


# =====================================================
# SPAWNING
# =====================================================

func spawn_match(peer_a:int, peer_b:int):

	var spawn_a : Marker2D = player_spawns.pick_random()
	var spawn_b : Marker2D = enemy_spawns.pick_random()

	# --- Player A ---
	var champ_a = CHAMPION_SCENE.instantiate()
	champ_a.global_position = spawn_a.global_position
	champ_a.set_multiplayer_authority(peer_a)

	multiplayer_spawner.add_child(champ_a)

	# --- Player B ---
	var champ_b = CHAMPION_SCENE.instantiate()
	champ_b.global_position = spawn_b.global_position
	champ_b.set_multiplayer_authority(peer_b)

	multiplayer_spawner.add_child(champ_b)
