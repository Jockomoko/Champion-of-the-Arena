extends Node
class_name AbilityComponent

# Keys into AbilityRegistry
var equipped_ability_ids: Array[String] = []

func get_available_abilities() -> Array[Ability]:
	# Always available
	var available: Array[Ability] = [
		AbilitiesDataBase.get_ability("Melee Attack"),
		AbilitiesDataBase.get_ability("Rest")
	]
	# From equipment
	for ability_name in equipped_ability_ids:
		var ability = AbilitiesDataBase.get_ability(ability_name)
		available.append(ability)
	return available

func equip_ability(ability_name: String) -> void:
	if AbilitiesDataBase.abilities.has(ability_name):
		equipped_ability_ids.append(ability_name)

func unequip_ability(ability_name: String) -> void:
	equipped_ability_ids.erase(ability_name)
