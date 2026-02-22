extends Node

# =====================================
# GAME CONTROLLER FOR MULTIPLAYER
# =====================================

# Scenes
const CITY_SCENE := "res://Scenes/gameScene/CityScene/CityScene.tscn"
const ARENA_SCENE := "res://Scenes/gameScene/ArenaScene/Arena_Scene.tscn"

# Round settings
var city_wait_time := 60 # seconds in city before arena
var current_lobby_id := Globals.LOBBY_ID

# Multiplayer state
var is_host := false
var countdown_running := false

# Signals
signal countdown_updated(time_left:int)
signal arena_started(opponent_id:int)

# =========================
# LOBBY SETUP
# =========================
func set_lobby(lobby_id:int) -> void:
	current_lobby_id = lobby_id
	var owner = Steam.getLobbyOwner(lobby_id)
	var me = Steam.getSteamID()
	is_host = (owner == me)
	print("Am I host:", is_host)

	# Host immediately loads city scene and starts countdown
	if is_host:
		load_city_scene()

# =========================
# CITY SCENE & COUNTDOWN
# =========================
func load_city_scene() -> void:
	get_tree().change_scene_to_file(CITY_SCENE)

	if not is_host:
		return

	# Host stores the city countdown in lobby
	var end_time = Time.get_unix_time_from_system() + city_wait_time
	Steam.setLobbyData(current_lobby_id, "city_end_time", str(end_time))
	countdown_running = true
	_host_city_countdown(end_time)

# Host countdown loop
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
	if current_lobby_id == 0:
		return

	var end_time_str = Steam.getLobbyData(current_lobby_id, "city_end_time")
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
func start_arena() -> void:
	# Pick a random opponent from lobby
	var member_count = Steam.getNumLobbyMembers(current_lobby_id)
	var my_id = Steam.getSteamID()
	var opponent_id = 0

	# Select random player that isn’t self
	var others := []
	for i in range(member_count):
		var steam_id = Steam.getLobbyMemberByIndex(current_lobby_id, i)
		if steam_id != my_id:
			others.append(steam_id)

	if others.size() > 0:
		opponent_id = others[randi() % others.size()]

	# Update lobby so clients know arena started
	if is_host:
		Steam.setLobbyData(current_lobby_id, "scene", "arena")

	emit_signal("arena_started", opponent_id)
	get_tree().change_scene_to_file(ARENA_SCENE)

# Client joins arena if host already triggered
func _go_to_arena():
	get_tree().change_scene_to_file(ARENA_SCENE)
