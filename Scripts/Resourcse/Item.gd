# ItemResource.gd
extends Resource
class_name Item

# ------------------------------
# Basic identity
# ------------------------------
@export var id: String = ""         # unique identifier
@export var name: String = "Unnamed Item"
@export var description: String = ""

# Use an int dropdown for slot based on EquipmentComponent.VALID_SLOTS
@export var validSlotIndex = 1 as EquipmentComponent.VALID_SLOTS

# Cost in shop
@export var cost: int = 0

# Effects dictionary: can modify stats, health, armor, speed, etc.
# Example: {"attack": 10, "armor": 5, "health": 20, "speed": 2}
@export var modifiers: Dictionary = {
	"attack": 1.0,
	"defense": 1.0,
	"health": 1.0,
	"speed": 1.0,
	"mana": 1.0
}

# ------------------------------
# Helper methods
# ------------------------------

# Apply the effects to the hero node
func apply(hero) -> void:
	for stat in modifiers.keys():
		match stat:
			"attack":
				hero.stats.apply_modifier("attack", modifiers[stat])
			"speed":
				hero.stats.apply_modifier("speed", modifiers[stat])
			"defense":
				hero.stats.apply_modifier("defense", modifiers[stat])
			"health":
				hero.health.max_health += modifiers[stat]
				hero.health.current_health += modifiers[stat]
			"armor":
				if hero.has_node("ArmorComponent"):
					hero.get_node("ArmorComponent").apply_modifier(modifiers[stat])
