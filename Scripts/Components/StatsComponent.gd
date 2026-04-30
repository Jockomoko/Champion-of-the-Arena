extends Node
class_name StatsComponent

# ------------------------------
# Core stats stored as a dictionary
# ------------------------------
# Base stats
var base_stats: Dictionary = {
	"attack": 5.0,
	"defense": 5.0,
	"health": 5.0,
	"speed": 5.0,
	"mana": 5.0
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
func get_attack() -> float:
	return get_stat("attack")

func get_defense() -> float:
	return get_stat("defense")

func get_health() -> float:
	return get_stat("health")

func get_speed() -> float:
	return get_stat("speed")

func get_mana() -> float:
	return get_stat("mana")

# ------------------------------
# Level up increases base stats
# ------------------------------
func level_up():
	base_stats["attack"] += 2.0
	base_stats["defense"] += 1.0
	base_stats["health"] += 5.0
	base_stats["speed"] += 1.0
	base_stats["mana"] += 5.0

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
