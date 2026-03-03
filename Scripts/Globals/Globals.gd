extends Node

# ── Steam ─────────────────────────────────────
var STEAM_NAME: String = ""
var STEAM_ID: int = 0
const APP_ID: int = 480

# ── Lobby ─────────────────────────────────────
var LOBBY_ID: int = 0
var LOBBY_MEMBERS: Dictionary = {}
var LOBBY_INVITE_ARG: bool = false

# ── Network ───────────────────────────────────
var is_host: bool = false

# ── Game ──────────────────────────────────────
var MY_PLAYERCONTROLLER: PlayerController
const SAVED_CHAMPION_PATH = "user://champion_stats.json"
# ─────────────────────────────────────────────
#  Signals (LobbyScene listens to these)
# ─────────────────────────────────────────────
signal member_updated(steam_id: int, chat_state: int)

func _ready() -> void:
	var INIT = Steam.steamInitEx(APP_ID, false)
	if INIT["status"] != Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed: ", INIT["verbal"])
		get_tree().quit()
		return

	STEAM_ID   = Steam.getSteamID()
	STEAM_NAME = Steam.getPersonaName()
	print("Steam initialised — ID: %d  Name: %s" % [STEAM_ID, STEAM_NAME])

	# ── All Steam signals connected here permanently ──
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_fail)

	_check_command_line()


func _process(_delta: float) -> void:
	Steam.run_callbacks()


# ─────────────────────────────────────────────
#  Lobby helpers (called from LobbyScene)
# ─────────────────────────────────────────────

func create_lobby(max_members: int = 6) -> void:
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, max_members)


func leave_lobby() -> void:
	if LOBBY_ID == 0:
		return
	Steam.leaveLobby(LOBBY_ID)
	LOBBY_ID = 0
	LOBBY_MEMBERS.clear()
	is_host = false
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null


func populate_lobby_members() -> void:
	LOBBY_MEMBERS.clear()
	var member_count = Steam.getNumLobbyMembers(LOBBY_ID)
	for i in range(member_count):
		var steam_id    = Steam.getLobbyMemberByIndex(LOBBY_ID, i)
		var player_name = Steam.getFriendPersonaName(steam_id)
		LOBBY_MEMBERS[steam_id] = { "name": player_name }
		print("LOBBY_MEMBERS: %s | %d" % [player_name, steam_id])


# ─────────────────────────────────────────────
#  Steam callbacks
# ─────────────────────────────────────────────

func _on_lobby_created(connect: int, lobby_id: int) -> void:
	if connect != 1:
		print("Lobby creation failed: ", connect)
		return

	LOBBY_ID = lobby_id
	is_host  = true

	Steam.setLobbyData(LOBBY_ID, "name", STEAM_NAME + "'s Lobby")
	Steam.setLobbyJoinable(LOBBY_ID, true)

	var peer = SteamMultiplayerPeer.new()
	var err  = peer.create_host(0)
	if err != OK:
		print("Host peer creation failed: ", err)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(func(id):
		print("Globals: peer connected — ", id)
		print("Globals: all peers — ", multiplayer.get_peers())
	)

	populate_lobby_members()
	print("Lobby created: ", LOBBY_ID)


func _on_lobby_joined(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response != 1:
		print("Failed to join lobby: ", response)
		return

	LOBBY_ID = lobby_id
	is_host  = (Steam.getLobbyOwner(LOBBY_ID) == STEAM_ID)

	# Host peer was already created in _on_lobby_created
	if is_host:
		populate_lobby_members()
		member_updated.emit(STEAM_ID, 1)
		return

	# Client creates peer now
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	var peer = SteamMultiplayerPeer.new()
	var err  = peer.create_client(Steam.getLobbyOwner(LOBBY_ID), 0)
	if err != OK:
		print("Client peer creation failed: ", err)
		return

	multiplayer.multiplayer_peer = peer
	print("Globals: client peer set — host Steam ID: ", Steam.getLobbyOwner(LOBBY_ID))
	print("Globals: my peer ID: ", multiplayer.get_unique_id())

	populate_lobby_members()
	member_updated.emit(STEAM_ID, 1)


func _on_lobby_chat_update(lobby_id: int, change_id: int, _making_change_id: int, chat_state: int) -> void:
	if lobby_id != LOBBY_ID:
		return
	populate_lobby_members()
	member_updated.emit(change_id, chat_state)


func _on_lobby_join_requested(lobby_id: int, _steam_id: int) -> void:
	Steam.joinLobby(lobby_id)


func _on_p2p_session_request(remote_steam_id: int) -> void:
	print("P2P request from: ", remote_steam_id)
	Steam.acceptP2PSessionWithUser(remote_steam_id)


func _on_p2p_session_fail(remote_steam_id: int, error: int) -> void:
	print("P2P FAILED with: ", remote_steam_id, " error: ", error)


# ─────────────────────────────────────────────
#  Command-line lobby join (Steam overlay invite)
# ─────────────────────────────────────────────

func _check_command_line() -> void:
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.begins_with("+connect_lobby"):
			var lobby_id = int(arg.split(" ")[1])
			Steam.joinLobby(lobby_id)
			LOBBY_INVITE_ARG = true
