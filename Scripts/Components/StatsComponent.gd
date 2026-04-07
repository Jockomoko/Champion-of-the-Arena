extends Node
class_name StatsComponent

# ------------------------------
# Core stats stored as a dictionary
# ------------------------------
# Base stats
var base_stats: Dictionary = {
	"attack": 5,
	"defense": 5,
	"health": 5,
	"speed": 5,
	"mana": 5
}

# Modifiers applied from equipment, buffs, etc.
var modifiers: Dictionary = {
	"attack": 1.0,
	"defense": 1.0,
	"health": 1.0,
	"speed": 1.0,
	"mana": 1.0
}

# ------------------------------
# Get effective stats
# ------------------------------
func get_stat(stat_name: String) -> float:
	if base_stats.has(stat_name) and modifiers.has(stat_name):
		return base_stats[stat_name] * modifiers[stat_name]
	return 0

# Shortcut methods
func get_attack() -> int:
	return int(get_stat("attack"))

func get_defense() -> int:
	return int(get_stat("defense"))

func get_health() -> int:
	return int(get_stat("health"))

func get_speed() -> int:
	return int(get_stat("speed"))

func get_mana() -> int:
	return int(get_stat("mana"))

# ------------------------------
# Level up increases base stats
# ------------------------------
func level_up():
	base_stats["attack"] += 2
	base_stats["defense"] += 1
	base_stats["health"] += 5
	base_stats["speed"] += 1
	base_stats["mana"] += 5

# ------------------------------
# Apply a modifier (e.g., from an item)
# ------------------------------
func apply_modifier(stat_name: String, value: float) -> void:
	if modifiers.has(stat_name):
		modifiers[stat_name] *= value

# Remove a modifier
func remove_modifier(stat_name: String, value: float) -> void:
	if modifiers.has(stat_name):
		modifiers[stat_name] /= value
