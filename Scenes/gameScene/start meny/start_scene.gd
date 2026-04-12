extends Node2D

func _ready() -> void:
	Steam.join_requested.connect(_on_lobby_join_requested)
	Steam.lobby_joined.connect(_on_lobby_joined)

func _on_lobby_join_requested(lobby_id: int, steam_id: int) -> void:
	Steam.joinLobby(lobby_id)

func _on_lobby_joined(_lobby_id, _permissions, _locked, response) -> void:
	if response != 1:
		return
	get_tree().change_scene_to_file("res://Scenes/Lobby/LobbyScene.tscn")


func _on_quit_sign_pressed() -> void:
	get_tree().quit()

func _on_team_sign_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/gameScene/ChampionCreationScene/ChampionCreationScene.tscn")

func _on_start_sign_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Lobby/LobbyScene.tscn")
