extends Node2D

@onready var start_game_btn: TextureButton = $Control/Background/Start_Game_btn
@onready var signe_container: GridContainer = $Control/Sign/GridContainer

const PLAYER_PAPER = preload("uid://diuguoosinp8u")

var exit_path = "res://Scenes/gameScene/start meny/StartScene.tscn"
var start_path = "res://Scenes/gameScene/ArenaScene/Arena_Scene.tscn"

var max_player_amount := 6

# Add this for tracking lobby members
var current_lobby_members := []


func _ready() -> void:
	# --- Steam signals ---
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.join_requested.connect(_on_lobby_join_requested)

	check_command_line()
	create_lobby()


# =====================================================
# LOBBY EVENTS
# =====================================================

func _on_lobby_created(connect, lobby_id):
	if connect != 1:
		return
	
	Globals.LOBBY_ID = lobby_id
	print("Lobby created: ", lobby_id)
	print("Lobby owner: ", Steam.getLobbyOwner(lobby_id))

	Steam.setLobbyData(lobby_id, "name", Globals.STEAM_NAME + "'s Lobby")
	Steam.setLobbyJoinable(lobby_id, true)

	rebuild_player_papers()


func _on_lobby_joined(lobby_id, permissions, locked, response):
	Globals.LOBBY_ID = lobby_id
	rebuild_player_papers()


func _on_lobby_data_update(success, lobby_id, member_id):
	if lobby_id != Globals.LOBBY_ID:
		return

	rebuild_player_papers()

	# Detect joins/leaves by comparing current members with cached list
	var new_members := []
	var member_count = Steam.getNumLobbyMembers(Globals.LOBBY_ID)
	for i in range(member_count):
		new_members.append(Steam.getLobbyMemberByIndex(Globals.LOBBY_ID, i))

	# Detect joins
	for steam_id in new_members:
		if not current_lobby_members.has(steam_id):
			# New player joined
			if Steam.getSteamID() != Steam.getLobbyOwner(Globals.LOBBY_ID):
				# Client tells host about their controller
				notify_host_controller_ready()
			else:
				# Host placeholder registration
				GameController.rpc_id(
					1,
					"player_joined",
					steam_id,
					null,
					Steam.getFriendPersonaName(steam_id)
				)

	# Detect leaves
	for steam_id in current_lobby_members:
		if not new_members.has(steam_id):
			# Player left
			if Steam.getSteamID() == Steam.getLobbyOwner(Globals.LOBBY_ID):
				GameController.rpc_id(1, "player_left", steam_id)

	current_lobby_members = new_members


func _on_lobby_join_requested(lobby_id, steam_id):
	Steam.joinLobby(lobby_id)


# =====================================================
# PLAYER UI
# =====================================================

func rebuild_player_papers():
	var paper_slots := signe_container.get_children()
	
	# Reset paper slots
	for slot in paper_slots:
		for child in slot.get_children():
			child.queue_free()
	
	if Globals.LOBBY_ID == 0:
		return

	var member_count := Steam.getNumLobbyMembers(Globals.LOBBY_ID)

	for i in range(member_count):
		if paper_slots[i] == null:
			continue
		
		var steam_id = Steam.getLobbyMemberByIndex(Globals.LOBBY_ID, i)
		var player_name = Steam.getFriendPersonaName(steam_id)
		var avatar_id = Steam.getMediumFriendAvatar(steam_id)
		var avatar_texture = get_avatar_texture(avatar_id)
		
		add_player_paper_to_sign(avatar_texture, player_name, paper_slots[i])


func add_player_paper_to_sign(player_picture: Texture2D, player_name: String, paper_slot : Control):
	var new_player_paper = PLAYER_PAPER.instantiate()
	new_player_paper.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	new_player_paper.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
	new_player_paper.Player_Paper(player_picture, player_name)
	paper_slot.add_child(new_player_paper)


# =====================================================
# STEAM AVATAR → TEXTURE
# =====================================================

func get_avatar_texture(avatar_id: int) -> Texture2D:
	if avatar_id <= 0:
		return null

	var size = Steam.getImageSize(avatar_id)
	if not size.has("width") or not size.has("height"):
		return null

	var width = size["width"]
	var height = size["height"]

	if width <= 0 or height <= 0:
		return null

	var result = Steam.getImageRGBA(avatar_id)
	if not result.has("buffer"):
		return null

	var data: PackedByteArray = result["buffer"]
	if data.size() == 0:
		return null

	var image : Image = Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, data)
	return ImageTexture.create_from_image(image)


# =====================================================
# COMMAND LINE JOIN (Steam Invite)
# =====================================================

func check_command_line():
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.begins_with("+connect_lobby"):
			var lobby_id = int(arg.split(" ")[1])
			Steam.joinLobby(lobby_id)


func create_lobby():
	print("Creating lobby...")
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, max_player_amount)


func leave_lobby():
	if Globals.LOBBY_ID != 0:
		Steam.leaveLobby(Globals.LOBBY_ID)
		Globals.LOBBY_ID = 0


# =====================================================
# BUTTONS / UI
# =====================================================

func _rotate_button(button: TextureButton, angle: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "rotation", angle, 0.15)


func _on_exit_btn_pressed() -> void:
	leave_lobby()
	get_tree().change_scene_to_file(exit_path)


func _on_exit_btn_mouse_entered() -> void:
	_rotate_button($Control/Background/TextureRect/Exit_btn, 0.1)


func _on_exit_btn_mouse_exited() -> void:
	_rotate_button($Control/Background/TextureRect/Exit_btn, 0.0)


func _on_start_game_btn_pressed() -> void:
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID:
		return  # only host can start

	GameController.lobby_players.clear()

	var member_count = Steam.getNumLobbyMembers(Globals.LOBBY_ID)

	for i in range(member_count):
		var steam_id = Steam.getLobbyMemberByIndex(Globals.LOBBY_ID, i)
		var player_name = Steam.getFriendPersonaName(steam_id)
		var controller: PlayerController = null

		if steam_id == Globals.STEAM_ID:
			# Host registers its own controller locally
			controller = Globals.MY_PLAYERCONTROLLER

		# Register placeholder for others; clients will send their controllers via RPC
		GameController.lobby_players[steam_id] = { "controller": controller, "name": player_name }

	# Start arena (host can check controllers are ready)
	GameController.start_arena()



func _on_start_game_btn_mouse_entered() -> void:
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID:
		return
	start_game_btn.show_behind_parent = false


func _on_start_game_btn_mouse_exited() -> void:
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID:
		return
	start_game_btn.show_behind_parent = true


# =====================================================
# CLIENT → HOST CONTROLLER NOTIFICATION
# =====================================================

func notify_host_controller_ready():
	GameController.rpc_id(
		1,  # host
		"player_joined",
		Globals.STEAM_ID,
		Globals.MY_PLAYERCONTROLLER,
		Globals.STEAM_NAME
	)
