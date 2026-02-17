extends Node
class_name TeamComponent

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
	
	# Loop through champion1, champion2, etc
	for champion_name in data.keys():
		var champ := Champion.new()
		champ.name = champion_name
		champ.stats = StatsComponent.new()
		
		var stat_point_left : int = stats_points
		
		for stat_name in champ.stats.base_stats.keys():
			
			var default_value : int = champ.stats.base_stats[stat_name]
			var loaded_value : int = data[champion_name].get(stat_name, default_value)
			
			var requested_increase := loaded_value - default_value
			
			# Only increases cost points
			if requested_increase > 0:
				
				# Player wants more than remaining points
				if requested_increase > stat_point_left:
					requested_increase = stat_point_left
				
				stat_point_left -= requested_increase
			
			# Apply final stat value
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
