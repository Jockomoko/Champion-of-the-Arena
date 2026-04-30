extends Node
class_name TeamComponent

const CHAMPIONS = preload("uid://d2xtwn0w40ncd")
const saved_champion_path = "user://champion_stats.json"

var champions: Array[Champion] = []
var stats_points: int = 6
var skip_load := false

func _ready() -> void:
	if skip_load:
		return
	var file = FileAccess.open(saved_champion_path, FileAccess.READ)
	if not file:
		print("No save file found")
		return
	var text := file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)
	if data == null:
		print("Failed to parse JSON")
		return
	
	champions.clear()
	for key in ["champion1", "champion2"]:
		if data.has(key):
			var result = add_champion_to_team(data[key])
			if not result:
				print("Failed to load: ", key)

func is_stats_valid_to_load(loaded_stats: Dictionary) -> bool:
	var stat_points_left: float = stats_points
	var champion := StatsComponent.new()

	for stat_name in champion.base_stats.keys():
		var default_value: float = champion.base_stats[stat_name]
		var loaded_value: float = loaded_stats.get(stat_name, default_value)
		var increase := loaded_value - default_value
		if increase > 0:
			stat_points_left -= increase
			if stat_points_left < 0:
				return false
	return true

func add_champion_to_team(loaded_data: Dictionary) -> bool:
	if not loaded_data.has("name") || loaded_data["name"] == null || loaded_data["name"] == "":
		return false
	if not loaded_data.has("stats") || !is_stats_valid_to_load(loaded_data["stats"]):
		return false
	if not loaded_data.has("appearance") || !is_appearance_valid_to_load(loaded_data["appearance"]):
		return false
	
	var champion := CHAMPIONS.instantiate()
	champion.champion_name = loaded_data["name"]
	champion.appearance.set_appearance(loaded_data["appearance"])
	
	for stat_name in loaded_data["stats"].keys():
		champion.set_stat(stat_name, loaded_data["stats"][stat_name])
	
	champions.append(champion)
	return true

func clear_champions_team() -> void:
	champions.clear()

func get_team_data() -> Array:
	var data = []
	for champion in champions:
		data.append(champion.get_dictionary())
	return data

func is_appearance_valid_to_load(appearance_data: Dictionary) -> bool:
	var required_keys = AppearanceComponent.new().to_dict().keys()
	
	for key in required_keys:
		if not appearance_data.has(key):
			return false
		if key in ["body_color", "hair_color"]:
			if not appearance_data[key] is String:
				return false
			var color = Color(appearance_data[key])
			if color.a == 0:
				return false
		if key in ["hair_id", "eye_id", "mouth_id"]:
			if not (appearance_data[key] is int or appearance_data[key] is float):
				return false
			if appearance_data[key] < 0:
				return false
	
	return true
