extends Node

var abilities: Dictionary[String, Ability] = {}

func _ready() -> void:
	_register_abilities()

func _register_abilities() -> void:
	# Defaults
	abilities["melee_attack"] = preload("res://Scripts/Resourcse/Abilities/melee.tres")
	abilities["rest"] = preload("res://Scripts/Resourcse/Abilities/rest.tres")
	# Spells
	abilities["fireball"] = preload("res://Scripts/Resourcse/Abilities/fireball.tres")

func get_ability(ability_id: String) -> Ability:
	if not abilities.has(ability_id):
		push_error("AbilitiesDataBase: unknown ability id '%s'" % ability_id)
		return null
	return abilities[ability_id]
