extends Node2D

@onready var signe_container: GridContainer = $Control/Sign/GridContainer

const PLAYER_PAPER = preload("uid://diuguoosinp8u")

var current_lobby_id : int = 0
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
		current_lobby_id = lobby_id

		print("Lobby created:", lobby_id)

		# Optional but important
		Steam.setLobbyData(lobby_id, "name", Globals.STEAM_NAME + "'s Lobby")
		Steam.setLobbyJoinable(lobby_id, true)

		rebuild_player_papers()



func _on_lobby_joined(lobby_id, permissions, locked, response):
	current_lobby_id = lobby_id
	rebuild_player_papers()


# Called when players join/leave
func _on_lobby_chat_update(lobby_id, changed_id, making_change_id, chat_state):
	if lobby_id == current_lobby_id:
		rebuild_player_papers()


func _on_lobby_data_update(success, lobby_id, member_id):
	if lobby_id == current_lobby_id:
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
	
	if current_lobby_id == 0:
		return

	var member_count := Steam.getNumLobbyMembers(current_lobby_id)

	for i in range(member_count):
		if paper_slots[i] == null:
			continue
		
		var steam_id = Steam.getLobbyMemberByIndex(current_lobby_id, i)
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
