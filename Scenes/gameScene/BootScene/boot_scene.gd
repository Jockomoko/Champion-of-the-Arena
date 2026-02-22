extends Node

var player : PlayerController
const SAVE_PATH = Globals.SAVED_CHAMPION_PATH
const START_SCENE := "res://Scenes/gameScene/start meny/StartScene.tscn"
const CHAMPION_CREATION_SCENE := "res://Scenes/gameScene/ChampionCreationScene/ChampionCreationScene.tscn"

func _ready():
	if !FileAccess.file_exists(SAVE_PATH):
		call_deferred("load_scene", CHAMPION_CREATION_SCENE)
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if not file:
		call_deferred("load_scene", CHAMPION_CREATION_SCENE)
		return
	
	var text := file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(text)
	
	if data == null:
		call_deferred("load_scene", CHAMPION_CREATION_SCENE)
	
	var ChampionsTeam := TeamComponent.new()
	
	for champion_name in data.keys() :
		if  !ChampionsTeam.is_stats_valid_to_load(data[champion_name]) :
			call_deferred("load_scene", CHAMPION_CREATION_SCENE)
		
	player = PlayerController.new()
	call_deferred("load_scene", START_SCENE)

func load_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
