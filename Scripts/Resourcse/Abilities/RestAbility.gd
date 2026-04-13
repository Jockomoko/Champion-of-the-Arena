extends Ability
class_name RestAbility

func apply(attacker: Champion, target: Champion) -> Dictionary:
	return {
		"mana_change": mana_restore - mana_cost,
		"stat_bonus": stat_bonus,
	}
