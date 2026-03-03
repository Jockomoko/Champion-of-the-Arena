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


# =========================
# PLAYER JOIN / LEFT  (RPCs)
# =========================

@rpc("any_peer", "reliable", "call_local")
func player_joined(steam_id: int, player_name: String) -> void:
	print("Player joined: ", player_name, " | ", steam_id)
	Globals.LOBBY_MEMBERS[steam_id] = { "name": player_name }


@rpc("any_peer", "reliable", "call_local")
func player_left(steam_id: int) -> void:
	Globals.LOBBY_MEMBERS.erase(steam_id)
	print("Player left, SteamID: ", steam_id)


# =========================
# LOBBY → GAME START
# =========================

# Called by LobbyScene start button (host only).
func start_game() -> void:
	if not Globals.is_host:
		return

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
		countdown_updated.emit(time_left)
		if time_left <= 0:
			countdown_running = false
			start_arena()
			return
		await get_tree().create_timer(1.0).timeout


# Clients call this when they receive a lobby_data_update for "city_end_time".
func on_lobby_data_updated() -> void:
	if Globals.LOBBY_ID == 0:
		return
	var end_time_str := Steam.getLobbyData(Globals.LOBBY_ID, "city_end_time")
	if end_time_str == "":
		return
	var end_time  := int(end_time_str)
	var now       := Time.get_unix_time_from_system()
	var time_left := int(max(end_time - now, 0))
	countdown_updated.emit(time_left)
	if time_left <= 0:
		_go_to_arena.rpc()


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
	get_tree().change_scene_to_file(
		"res://Scenes/Lobby/LobbyScene.tscn"
	)
