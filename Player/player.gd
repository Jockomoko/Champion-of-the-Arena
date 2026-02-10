extends Node2D
class_name PlayerManager

@onready var champions: Array[Champion] = []

# Preload Champion scene
var champion_scene := preload("res://Champions/Champions.tscn")

# Steam module (GodotSteam)
@onready var steam := $GodotSteam

# List of Steam Cloud save filenames
var champion_files := ["champion1.json", "champion2.json"]

func _ready() -> void:
	# Load champions from Steam Cloud
	for i in range(champion_files.size()):
		var data := load_champion_steam(champion_files[i])
		if data.is_empty():
			# No save exists → create a default champion
			var champion_name := "Champion%d" % (i + 1)
			_create_champion(champion_name, Vector2(200 + i * 200, 300))
		else:
			_create_champion_from_data(data, Vector2(200 + i * 200, 300))


# -----------------------------------------
# Builder: Create Champion node normally
# -----------------------------------------
func _create_champion(champion_name: String, spawn_position: Vector2 = Vector2.ZERO) -> Champion:
	var champ := champion_scene.instantiate() as Champion
	champ.champion_name = champion_name  # use parameter directly
	champ.position = spawn_position
	add_child(champ)
	champions.append(champ)
	return champ



# -----------------------------------------
# Builder: Create Champion from loaded data
# -----------------------------------------
func _create_champion_from_data(data: Dictionary, spawn_position: Vector2 = Vector2.ZERO) -> Champion:
	var champ := _create_champion(data.get("name", "Unnamed"), spawn_position)

	# Apply stats
	if data.has("stats"):
		for stat_name in data["stats"].keys():
			champ.stats.modifiers[stat_name] = data["stats"][stat_name]

	# Apply health
	if data.has("health"):
		champ.health.max_health = data["health"].get("max", champ.stats.get_health())
		champ.health.current_health = data["health"].get("current", champ.health.max_health)

	# Apply equipment
	if data.has("equipment"):
		for i in range(len(data["equipment"])):
			var item_data = data["equipment"][i]
			if item_data:
				champ.equipment.set_item_from_data(i, item_data)  # You need a helper in EquipmentComponent

	return champ


# -----------------------------------------
# Save all champions to Steam Cloud
# -----------------------------------------
func save_champions() -> void:
	for i in range(champions.size()):
		save_champion_steam(champions[i], champion_files[i])


# -----------------------------------------
# Save single champion to Steam Cloud
# -----------------------------------------
func save_champion_steam(champ: Champion, filename: String) -> void:
	var data := {
		"name": champ.champion_name,
		"stats": champ.stats.modifiers,
		"health": {
			"current": champ.health.current_health,
			"max": champ.health.max_health
		},
		"equipment": []
	}

	# Save equipped items
	for slot_item in champ.equipment.get_all_items():
		if slot_item:
			data["equipment"].append({
				"id": slot_item.item_id,
				"modifiers": slot_item.modifiers
			})
		else:
			data["equipment"].append(null)

	# Convert to JSON
	var json_str := JSON.stringify(data)
	# Write to Steam Cloud via GodotSteam
	steam.file_write(filename, json_str)


# -----------------------------------------
# Load champion data from Steam Cloud
# -----------------------------------------
func load_champion_steam(filename: String) -> Dictionary:
	if not steam.file_exists(filename):
		return {}
	var bytes: PackedByteArray = steam.file_read(filename)
	var json_str := bytes.get_string_from_utf8()
	var result = JSON.parse_string(json_str)
	if result.error != OK:
		return {}
	return result.result
