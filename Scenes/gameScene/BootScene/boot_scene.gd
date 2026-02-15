extends Node

const SAVE_PATH = Globals.SAVED_CHAMPION_PATH
const START_SCENE := "res://Scenes/gameScene/start meny/StartScene.tscn"
const CHAMPION_CREATION_SCENE := "res://Scenes/gameScene/ChampionCreationScene/ChampionCreationScene.tscn"

func _ready():
	if FileAccess.file_exists(SAVE_PATH):
		call_deferred("load_scene", START_SCENE)
	else:
		call_deferred("load_scene", CHAMPION_CREATION_SCENE)

func load_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
