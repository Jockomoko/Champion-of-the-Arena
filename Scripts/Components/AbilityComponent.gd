extends Node
class_name AbilityComponent

# Keys into AbilityRegistry
var equipped_ability_ids: Array[String] = []

func get_available_abilities() -> Array[Ability]:
	var available: Array[Ability] = []
	for id in ["melee_attack", "rest"] + equipped_ability_ids:
		var ability = AbilitiesDataBase.get_ability(id)
		if ability:
			available.append(ability)
	return available

func equip_ability(ability_name: String) -> void:
	if AbilitiesDataBase.abilities.has(ability_name):
		equipped_ability_ids.append(ability_name)

func unequip_ability(ability_name: String) -> void:
	equipped_ability_ids.erase(ability_name)
