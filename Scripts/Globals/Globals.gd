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
var MY_PLAYERCONTROLLER: PlayerController:
	set(value):
		MY_PLAYERCONTROLLER = value
		if value != null:
			player_controller_ready.emit(value)

var peer_to_steam: Dictionary = {}
var steam_to_peer: Dictionary = {}
# ─────────────────────────────────────────────
#  Signals (LobbyScene listens to these)
# ─────────────────────────────────────────────
signal player_controller_ready(controller: PlayerController)
signal member_updated(steam_id: int, chat_state: int)
signal player_disconnected(steam_id: int)

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
	peer_to_steam.clear()
	steam_to_peer.clear()
	is_host = false
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

 
func populate_lobby_members() -> void:
	var member_count = Steam.getNumLobbyMembers(LOBBY_ID)
	for i in range(member_count):
		var steam_id    = Steam.getLobbyMemberByIndex(LOBBY_ID, i)
		var player_name = Steam.getFriendPersonaName(steam_id)
		if not LOBBY_MEMBERS.has(steam_id):
			LOBBY_MEMBERS[steam_id] = {}
		LOBBY_MEMBERS[steam_id]["name"] = player_name
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
	steam_to_peer[STEAM_ID] = 1 
	peer_to_steam[1] = STEAM_ID
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)

	populate_lobby_members()
	print("Lobby created: ", LOBBY_ID)
	


func _on_peer_connected(peer_id: int) -> void:
	print("Globals: peer fully connected — ", peer_id)
	print("Globals: all peers — ", multiplayer.get_peers())
	member_updated.emit(peer_id, 1)
	await get_tree().create_timer(0.1).timeout
	_request_steam_id.rpc_id(peer_id)

@rpc("authority", "reliable")
func _request_steam_id() -> void:
	_register_steam_id.rpc_id(1, Globals.STEAM_ID)

@rpc("any_peer", "reliable")
func _register_steam_id(steam_id: int) -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	steam_to_peer[steam_id] = peer_id
	peer_to_steam[peer_id]  = steam_id
	print("Mapped Steam %d → Peer %d" % [steam_id, peer_id])

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
		return
	multiplayer.multiplayer_peer = peer
	
	print("Globals: client peer set — host Steam ID: ", Steam.getLobbyOwner(LOBBY_ID))
	print("Globals: my peer ID: ", multiplayer.get_unique_id())

	populate_lobby_members()


func _on_lobby_chat_update(lobby_id: int, change_id: int, _making_change_id: int, chat_state: int) -> void:
	if lobby_id != LOBBY_ID:
		return
	populate_lobby_members()
	member_updated.emit(change_id, chat_state)
	# chat_state 4 = player left
	if chat_state == 4:
		player_disconnected.emit(change_id)

const _JOINABLE_SCENES: Array[String] = [
	"res://Scenes/gameScene/start meny/StartScene.tscn",
	"res://Scenes/Lobby/LobbyScene.tscn",
]

func _on_lobby_join_requested(lobby_id: int, _steam_id: int) -> void:
	var current_scene = get_tree().current_scene.scene_file_path
	if current_scene not in _JOINABLE_SCENES:
		print("Invite ignored — not in main menu or lobby (current: %s)" % current_scene)
		return
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
