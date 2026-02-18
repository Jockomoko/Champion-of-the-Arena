extends Node

# =====================================
# GAME CONTROLLER FOR MULTIPLAYER
# =====================================

# Scenes
const CITY_SCENE := "res://Scenes/gameScene/CityScene/CityScene.tscn"
const ARENA_SCENE := "res://Scenes/gameScene/ArenaScene/Arena_Scene.tscn"

# Round settings
var round_length := 60 # seconds
var current_lobby_id := Globals.LOBBY_ID

# Multiplayer state
var is_host := false
var countdown_running := false

# Signals for UI
signal countdown_updated(time_left:int)
signal round_started()

# =====================================
# SET LOBBY
# =====================================
func set_lobby(lobby_id:int) -> void:
	current_lobby_id = lobby_id
	var owner = Steam.getLobbyOwner(lobby_id)
	var me = Steam.getSteamID()
	is_host = (owner == me)
	print("Am I host:", is_host)

	# Start round immediately if host
	if is_host:
		start_round()

# =====================================
# START ROUND (HOST ONLY)
# =====================================
func start_round() -> void:
	if !is_host:
		return

	countdown_running = true
	var end_time = Time.get_unix_time_from_system() + round_length

	# Store round end time in Steam lobby data
	Steam.setLobbyData(current_lobby_id, "round_end", str(end_time))

	_host_countdown_loop()

# =====================================
# HOST COUNTDOWN LOOP
# =====================================
func _host_countdown_loop() -> void:
	while countdown_running:
		var end_time = int(Steam.getLobbyData(current_lobby_id, "round_end"))
		var now = Time.get_unix_time_from_system()
		var time_left = max(end_time - now, 0)
		
		emit_signal("countdown_updated", time_left)
		
		if time_left <= 0:
			countdown_running = false
			start_arena()
			return
			
		await get_tree().create_timer(1.0).timeout

# =====================================
# CLIENT SYNC TIMER
# =====================================
func on_lobby_data_updated() -> void:
	if current_lobby_id == 0:
		return
	
	var end_time = int(Steam.getLobbyData(current_lobby_id, "round_end"))
	if end_time == 0:
		return
	
	_client_sync_timer(end_time)

func _client_sync_timer(end_time:int) -> void:
	while true:
		var now = Time.get_unix_time_from_system()
		var time_left = max(end_time - now, 0)

		emit_signal("countdown_updated", time_left)

		if time_left <= 0:
			start_arena()
			return

		await get_tree().create_timer(1.0).timeout

# =====================================
# ARENA TRANSITION
# =====================================
func start_arena() -> void:
	# Host updates lobby so clients know scene change
	if is_host:
		Steam.setLobbyData(current_lobby_id, "scene", "arena")
	
	emit_signal("round_started")
	get_tree().change_scene_to_file(ARENA_SCENE)

# =====================================
# OPTIONAL: RETURN TO LOBBY
# =====================================
func return_to_lobby() -> void:
	if is_host:
		Steam.setLobbyData(current_lobby_id, "scene", "lobby")
	get_tree().change_scene_to_file(CITY_SCENE)

	# Reset countdown for next round
	if is_host:
		start_round()
