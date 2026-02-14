extends Node

const SAVE_PATH := "user://test_save.json"
const START_SCENE := "res://Scenes/gameScene/start meny/StartScene.tscn"
const CHAMPION_CREATION_SCENE := "res://Scenes/gameScene/ChampionCreationScene/ChampionCreationScene.tscn"

func _ready():
	if FileAccess.file_exists("user://test_save.json"):
		call_deferred("load_scene", "res://Scenes/gameScene/start meny/StartScene.tscn")
	else:
		call_deferred("load_scene", "res://Scenes/gameScene/ChampionCreationScene/ChampionCreationScene.tscn")

func load_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
