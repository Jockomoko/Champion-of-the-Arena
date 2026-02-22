extends Node2D

@onready var start_game_btn: TextureButton = $Control/Background/Start_Game_btn
@onready var signe_container: GridContainer = $Control/Sign/GridContainer

const PLAYER_PAPER = preload("uid://diuguoosinp8u")

var exit_path = "res://Scenes/gameScene/start meny/StartScene.tscn"
var start_path = "res://Scenes/gameScene/ArenaScene/Arena_Scene.tscn"

var max_player_amount := 6


func _ready() -> void:

	# --- Steam signals ---
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	Steam.join_requested.connect(_on_lobby_join_requested)

	check_command_line()
	create_lobby()

# =====================================================
# LOBBY EVENTS
# =====================================================

func _on_lobby_created(connect, lobby_id):
	if connect == 1:
		Globals.LOBBY_ID = lobby_id
		
		print("Lobby created: ", lobby_id)
		print("Lobby owner: ", Steam.getLobbyOwner(lobby_id))
	
		# Optional but important
		Steam.setLobbyData(lobby_id, "name", Globals.STEAM_NAME + "'s Lobby")
		Steam.setLobbyJoinable(lobby_id, true)

		rebuild_player_papers()



func _on_lobby_joined(lobby_id, permissions, locked, response):
	Globals.LOBBY_ID = lobby_id
	rebuild_player_papers()


# Called when players join/leave
func _on_lobby_chat_update(lobby_id, changed_id, making_change_id, chat_state):
	if lobby_id == Globals.LOBBY_ID:
		rebuild_player_papers()


func _on_lobby_data_update(success, lobby_id, member_id):
	if lobby_id == Globals.LOBBY_ID:
		rebuild_player_papers()


func _on_lobby_join_requested(lobby_id, steam_id):
	Steam.joinLobby(lobby_id)


# =====================================================
# PLAYER UI
# =====================================================

func rebuild_player_papers():
	
	var paper_slots := signe_container.get_children()
	
	#Reset paper slot
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

	# Get image size
	var size = Steam.getImageSize(avatar_id)
	if not size.has("width") or not size.has("height"):
		return null

	var width = size["width"]
	var height = size["height"]

	if width <= 0 or height <= 0:
		return null

	# Get the RGBA bytes
	var result = Steam.getImageRGBA(avatar_id)
	if not result.has("buffer"):
		return null

	var data: PackedByteArray = result["buffer"]
	if data.size() == 0:
		return null

	# Create Image and Texture
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
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID :
		return
	GameController.set_lobby(Globals.LOBBY_ID)


func _on_start_game_btn_mouse_entered() -> void:
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID :
		return
	start_game_btn.show_behind_parent = false


func _on_start_game_btn_mouse_exited() -> void:
	if Steam.getLobbyOwner(Globals.LOBBY_ID) != Globals.STEAM_ID :
		return
	start_game_btn.show_behind_parent = true
