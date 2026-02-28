extends Node

# =====================================
# GAME CONTROLLER FOR MULTIPLAYER
# =====================================

# Scenes
const CITY_SCENE := "res://Scenes/gameScene/CityScene/CityScene.tscn"
const ARENA_SCENE := "res://Scenes/gameScene/ArenaScene/Arena_Scene.tscn"

# Round settings
var city_wait_time := 10 # seconds in city before arena

# Multiplayer state
var is_host := false
var countdown_running := false

# Signals
signal countdown_updated(time_left:int)
signal arena_started(opponent_id:int)


@rpc("any_peer", "reliable")
func player_left(steam_id: int) -> void:
	Globals.LOBBY_MEMBERS.erase(steam_id)
	print("Player left, SteamID:", steam_id)

# =========================
# LOBBY SETUP
# =========================
func set_lobby() -> void:
	var owner = Steam.getLobbyOwner(Globals.LOBBY_ID)
	var me = Steam.getSteamID()
	is_host = (owner == me)
	print("Am I host:", is_host)
	
	Globals.populate_lobby_members()
	
	# Host immediately loads city scene and starts countdown
	if is_host:
		load_city_scene.rpc()

# =========================
# CITY SCENE & COUNTDOWN
# =========================
@rpc("authority", "call_local", "reliable")
func load_city_scene() -> void:
	get_tree().change_scene_to_file(CITY_SCENE)

func _on_city_scene_loaded() -> void:
	if not is_host:
		return
	var end_time = int(Time.get_unix_time_from_system()) + city_wait_time
	Steam.setLobbyData(Globals.LOBBY_ID, "city_end_time", str(end_time))
	countdown_running = true
	_host_city_countdown(end_time)

func _host_city_countdown(end_time:int) -> void:
	while countdown_running:
		var now = Time.get_unix_time_from_system()
		var time_left = max(end_time - now, 0)
		emit_signal("countdown_updated", time_left)

		if time_left <= 0:
			countdown_running = false
			start_arena()
			return

		await get_tree().create_timer(1.0).timeout

# Client sync for countdown
func on_lobby_data_updated() -> void:
	if Globals.LOBBY_ID == 0:
		return

	var end_time_str = Steam.getLobbyData(Globals.LOBBY_ID, "city_end_time")
	if end_time_str == "":
		return

	var end_time = int(end_time_str)
	var now = Time.get_unix_time_from_system()
	var time_left = max(end_time - now, 0)

	# Update client countdown UI
	emit_signal("countdown_updated", time_left)

	if time_left <= 0:
		_go_to_arena()

# =========================
# ARENA TRANSITION
# =========================
# Called from GameController or Lobby when the round starts
func start_arena() -> void:
	_go_to_arena.rpc()

@rpc("authority", "call_local", "reliable")
func _go_to_arena():
	get_tree().change_scene_to_file(ARENA_SCENE)
