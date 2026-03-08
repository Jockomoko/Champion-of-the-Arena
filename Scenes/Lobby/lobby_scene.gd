extends Node2D

@onready var start_game_btn: TextureButton = $Control/Background/Start_Game_btn
@onready var signe_container: GridContainer = $Control/Sign/GridContainer

const PLAYER_PAPER = preload("uid://diuguoosinp8u")

var exit_path  = "res://Scenes/gameScene/start meny/StartScene.tscn"

var max_player_amount := 6

# =====================================================
# READY
# =====================================================

func _ready() -> void:
	Globals.member_updated.connect(_on_member_updated)
	multiplayer.peer_connected.connect(_on_peer_connected)

	if Globals.LOBBY_ID == 0:
		Globals.create_lobby(max_player_amount)
	else:
		rebuild_player_papers()
	
	_update_start_button()



# =====================================================
# LOBBY EVENTS  (forwarded from Globals)
# =====================================================

func _on_member_updated(_steam_id: int, _chat_state: int) -> void:
	rebuild_player_papers()
	_update_start_button()

func _on_peer_connected(peer_id: int) -> void:
	print("LobbyScene: peer connected — ", peer_id)
	_update_start_button()

func _update_start_button() -> void:
	if not Globals.is_host:
		start_game_btn.hide()
		return
	start_game_btn.show() 
	
	var lobby_count = Steam.getNumLobbyMembers(Globals.LOBBY_ID)
	var peer_count  = multiplayer.get_peers().size()  # doesn't count host itself
	var all_connected = lobby_count >= 2 and peer_count >= (lobby_count - 1)
	
	start_game_btn.disabled = not all_connected
	print("Peers connected: %d / %d needed" % [peer_count, lobby_count - 1])

# =====================================================
# PLAYER UI
# =====================================================

func rebuild_player_papers() -> void:
	var paper_slots := signe_container.get_children()

	for slot in paper_slots:
		for child in slot.get_children():
			child.queue_free()

	if Globals.LOBBY_ID == 0:
		return

	var member_count := Steam.getNumLobbyMembers(Globals.LOBBY_ID)
	for i in range(member_count):
		if i >= paper_slots.size():
			break
		var steam_id    = Steam.getLobbyMemberByIndex(Globals.LOBBY_ID, i)
		var player_name = Steam.getFriendPersonaName(steam_id)
		var avatar_id   = Steam.getMediumFriendAvatar(steam_id)
		var avatar_tex  = _get_avatar_texture(avatar_id)
		_add_player_paper(avatar_tex, player_name, paper_slots[i])


func _add_player_paper(picture: Texture2D, player_name: String, slot: Control) -> void:
	var paper = PLAYER_PAPER.instantiate()
	paper.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	paper.size_flags_vertical   = Control.SIZE_FILL | Control.SIZE_EXPAND
	paper.Player_Paper(picture, player_name)
	slot.add_child(paper)


# =====================================================
# STEAM AVATAR → TEXTURE
# =====================================================

func _get_avatar_texture(avatar_id: int) -> Texture2D:
	if avatar_id <= 0:
		return null
	var size = Steam.getImageSize(avatar_id)
	if not size.has("width") or not size.has("height"):
		return null
	var w = size["width"]
	var h = size["height"]
	if w <= 0 or h <= 0:
		return null
	var result = Steam.getImageRGBA(avatar_id)
	if not result.has("buffer"):
		return null
	var data: PackedByteArray = result["buffer"]
	if data.size() == 0:
		return null
	var image := Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)
	return ImageTexture.create_from_image(image)


func _on_start_game_btn_mouse_entered() -> void:
	if not Globals.is_host:
		return
	start_game_btn.show_behind_parent = false


func _on_start_game_btn_mouse_exited() -> void:
	if not Globals.is_host:
		return
	start_game_btn.show_behind_parent = true


# =====================================================
# EXIT
# =====================================================

func _on_exit_btn_pressed() -> void:
	Globals.leave_lobby()
	get_tree().change_scene_to_file(exit_path)


func _on_exit_btn_mouse_entered() -> void:
	_rotate_button($Control/Background/TextureRect/Exit_btn, 0.1)


func _on_exit_btn_mouse_exited() -> void:
	_rotate_button($Control/Background/TextureRect/Exit_btn, 0.0)


func _rotate_button(button: TextureButton, angle: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "rotation", angle, 0.15)


# =====================================================
# CLEANUP
# =====================================================

func _exit_tree() -> void:
	if Globals.member_updated.is_connected(_on_member_updated):
		Globals.member_updated.disconnect(_on_member_updated)
	if multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.disconnect(_on_peer_connected)


func _on_start_game_btn_pressed() -> void:
	if not Globals.is_host:
		return
	GameController.start_game()
