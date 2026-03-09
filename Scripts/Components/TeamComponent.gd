extends Node
class_name TeamComponent

const CHAMPIONS = preload("uid://d2xtwn0w40ncd")

var champions : Array[Champion] = []
const saved_champion_path = Globals.SAVED_CHAMPION_PATH
var stats_points : int = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func TeamComponent() -> void:
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

	for champion_name in data.keys():
		var champ := CHAMPIONS.instantiate()  # ← was Champion.new()
		champ.name = champion_name

		# champ.stats should already exist via @onready in the scene
		# so just set the values directly
		var stat_point_left := stats_points

		for stat_name in champ.stats.base_stats.keys():
			var default_value: int = champ.stats.base_stats[stat_name]
			var loaded_value: int = data[champion_name].get(stat_name, default_value)
			var requested_increase := loaded_value - default_value

			if requested_increase > 0:
				if requested_increase > stat_point_left:
					requested_increase = stat_point_left
				stat_point_left -= requested_increase

			champ.stats.base_stats[stat_name] = default_value + requested_increase

		champions.append(champ)

func is_stats_valid_to_load(loaded_stats: Dictionary) -> bool:
	var stat_points_left := stats_points
	var champion := StatsComponent.new()
	
	for stat_name in champion.base_stats.keys():
		var default_value : int = champion.base_stats[stat_name]
		var loaded_value : int = loaded_stats.get(stat_name, default_value)
		
		var increase := loaded_value - default_value
		
		if increase > 0:
			stat_points_left -= increase
			if stat_points_left < 0:
				return false
	return true

func add_champion_to_team(loaded_data: Dictionary) -> bool:
	if not loaded_data.has("name") || loaded_data["name"] == null || loaded_data["name"] == "":
		return false
	
	if not loaded_data.has("stats") || !is_stats_valid_to_load(loaded_data["stats"]) :
		return false
	
	if not loaded_data.has("appearance") || !is_appearance_valid_to_load(loaded_data["appearance"]):
		return false
	
	var champion := CHAMPIONS.instantiate()
	champion.champion_name = loaded_data["name"]
	champion.appearance.load_apperance(loaded_data["appearance"])
	
	for stat_name in loaded_data["stats"].keys():
		champion.set_stat(stat_name, loaded_data["stats"][stat_name])
	
	champions.append(champion)
	return true

func clear_champions_team():
	champions.clear()

func get_team_data() -> Array:
	var data = []
	for champion in champions:
		data.append(champion.get_dictionary())
	return data

func is_appearance_valid_to_load(appearance_data: Dictionary) -> bool:
	var required_keys = AppearanceComponent.new().to_dict().keys()
	
	for key in required_keys:
		# Check key exists
		if not appearance_data.has(key):
			return false
		
		# Check color strings are not transparent
		if key in ["body_color", "hair_color"]:
			if not appearance_data[key] is String:
				return false
			var color = Color(appearance_data[key])
			if color.a == 0:
				return false
		
		# Check IDs are valid integers
		if key in ["hair_style", "eye_id", "mouth_id"]:
			if not (appearance_data[key] is int or appearance_data[key] is float):
				return false
			if appearance_data[key] < 0:
				return false
	
	return true
