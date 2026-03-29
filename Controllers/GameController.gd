extends Node

# =====================================
# GAME CONTROLLER FOR MULTIPLAYER
# =====================================

const CITY_SCENE  := "res://Scenes/gameScene/CityScene/CityScene.tscn"
const ARENA_SCENE := "res://Scenes/gameScene/ArenaScene/Arena_Scene.tscn"

var city_wait_time    := 10
var countdown_running := false

signal countdown_updated(time_left: int)
signal arena_started(opponent_id: int)

func _ready() -> void:
	RoundController.all_matches_done.connect(_on_all_matches_done)
	Globals.player_disconnected.connect(_on_player_disconnected)

@rpc("any_peer", "reliable", "call_local")
func player_left(steam_id: int) -> void:
	Globals.LOBBY_MEMBERS.erase(steam_id)
	print("Player left, SteamID: ", steam_id)

func _on_player_disconnected(steam_id: int) -> void:
	if not Globals.is_host:
		return
	print("Player disconnected: ", steam_id)
	
	# If they were in an active match, auto-report them as loser
	if RoundController.current_matches.has(steam_id):
		var opponent_id = RoundController.current_matches[steam_id]
		RoundController.report_match_result(opponent_id, steam_id)
	
	# Remove from future rounds
	RoundController.active_players.erase(steam_id)
	Globals.LOBBY_MEMBERS.erase(steam_id)
# =========================
# LOBBY → GAME START
# =========================

# Called by LobbyScene start button (host only).
func start_game() -> void:
	if not Globals.is_host:
		return
	Steam.setLobbyJoinable(Globals.LOBBY_ID, false)
	Globals.populate_lobby_members()

	var player_ids = Globals.LOBBY_MEMBERS.keys()
	print("Starting game — peers: ", multiplayer.get_peers())
	print("Lobby members: ", player_ids)

	RoundController.start_round(player_ids)
	
	load_city_scene.rpc()


# =========================
# CITY SCENE & COUNTDOWN
# =========================

@rpc("authority", "call_local", "reliable")
func load_city_scene() -> void:
	get_tree().change_scene_to_file(CITY_SCENE)


# Call this from CityScene._ready() so the countdown starts
# after the scene is fully loaded on the host.
func on_city_scene_ready() -> void:
	countdown_running = false  # reset before starting new countdown
	if not Globals.is_host:
		return
	var end_time := int(Time.get_unix_time_from_system()) + city_wait_time
	Steam.setLobbyData(Globals.LOBBY_ID, "city_end_time", str(end_time))
	countdown_running = true
	_host_city_countdown(end_time)


func _host_city_countdown(end_time: int) -> void:
	while countdown_running:
		var now       := Time.get_unix_time_from_system()
		var time_left := int(max(end_time - now, 0))
		_sync_countdown.rpc(time_left)
		if time_left <= 0:
			countdown_running = false
			start_arena()
			return
		await get_tree().create_timer(1.0).timeout

@rpc("authority", "call_local", "reliable")
func _sync_countdown(time_left: int) -> void:
	countdown_updated.emit(time_left)

func on_lobby_data_updated() -> void:
	pass


# =========================
# ARENA TRANSITION
# =========================

func start_arena() -> void:
	_go_to_arena.rpc()


@rpc("authority", "call_local", "reliable")
func _go_to_arena() -> void:
	get_tree().change_scene_to_file(ARENA_SCENE)

# =========================
# RETURN TO LOBBY
# =========================

func return_to_lobby() -> void:
	if not Globals.is_host:
		return
	_load_lobby.rpc()

@rpc("authority", "call_local", "reliable")
func _load_lobby() -> void:
	if Globals.is_host:
		Steam.setLobbyJoinable(Globals.LOBBY_ID, true)
	get_tree().change_scene_to_file(
		"res://Scenes/Lobby/LobbyScene.tscn"
	)

func _on_all_matches_done() -> void:
	if not Globals.is_host:
		return
	# Small delay so players can see the result before transitioning
	await get_tree().create_timer(2.0).timeout
	load_city_scene.rpc()
