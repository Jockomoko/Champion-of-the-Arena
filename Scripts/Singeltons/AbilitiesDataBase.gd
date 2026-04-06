extends Node

var abilities: Dictionary[String, Ability] = {}

func _ready() -> void:
	_register_abilities()

func _register_abilities() -> void:
	# Defaults
	abilities["melee"] = preload("res://Scripts/Resourcse/Abilities/melee.tres")
	abilities["rest"] = preload("res://Scripts/Resourcse/Abilities/rest.tres")
	# Spells
	abilities["fireball"] = preload("res://Scripts/Resourcse/Abilities/fireball.tres")

func has_ability(ability_id: String) -> bool:
	return abilities.has(ability_id.to_lower())

func get_ability(ability_id: String) -> Ability:
	var key = ability_id.to_lower()
	if not abilities.has(key):
		push_error("AbilitiesDataBase: unknown ability id '%s'" % ability_id)
		return null
	return abilities[key]
