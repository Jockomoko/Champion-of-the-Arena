extends Node2D

@onready var start_btn: TextureButton = $Buttons/Start_btn
@onready var quit_btn: TextureButton = $Buttons/Quit_btn

func _ready() -> void:
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_joined.connect(_on_lobby_joined)

func _on_lobby_join_requested(lobby_id: int, steam_id: int) -> void:
	Steam.joinLobby(lobby_id)

func _on_lobby_joined(_lobby_id, _permissions, _locked, response) -> void:
	if response != 1:
		return
	get_tree().change_scene_to_file("res://Scenes/Lobby/LobbyScene.tscn")

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _rotate_button(button: TextureButton, angle: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "rotation", angle, 0.15)


func _on_quit_btn_mouse_entered():
	_rotate_button(quit_btn, 0.1)

func _on_quit_btn_mouse_exited():
	_rotate_button(quit_btn, 0.0)

func _on_start_btn_mouse_entered():
	_rotate_button(start_btn, 0.1)

func _on_start_btn_mouse_exited():
	_rotate_button(start_btn, 0.0)

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Lobby/LobbyScene.tscn")


func _on_team_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/gameScene/ChampionCreationScene/ChampionCreationScene.tscn")
