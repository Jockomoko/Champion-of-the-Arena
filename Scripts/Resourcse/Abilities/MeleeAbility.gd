extends Ability
class_name MeleeAbility

func apply(attacker: Champion, target: Champion) -> Dictionary:
	return {
		"damage": get_damage(attacker.stats),
		"mana_change": mana_restore - mana_cost,
	}
