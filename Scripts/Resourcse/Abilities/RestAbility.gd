extends Ability
class_name RestAbility

func get_valid_targets(attacker: Champion, player_champions: Array[Champion], all_champions: Array[Champion]) -> Array[Champion]:
	return [attacker]

func apply(caster: Champion, target: Champion) -> void:
	await caster.play_ability_animation("Rest")
	_apply_effects(caster, caster)

func _apply_effects(caster: Champion, target: Champion) -> void:
	super._apply_effects(caster, target)
	caster.health.heal(10 + calc_stat_scaling(caster.stats))
