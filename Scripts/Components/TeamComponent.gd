extends Node
class_name TeamComponent

var champions : Array[Champion] = []
const saved_champion_path = Globals.SAVED_CHAMPION_PATH

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_champion() -> void:
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
		champ.stats.base_stats = data[champion_name]
		
		champions.append(champ)
