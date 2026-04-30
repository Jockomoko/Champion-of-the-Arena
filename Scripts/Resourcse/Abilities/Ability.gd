extends Resource
class_name Ability

enum TargetMode { ENEMY, ALLY }

const default_Icon = preload("uid://dfu43kjmmua2x")

@export var icon : Texture2D = default_Icon
@export var id: String = ""
@export var ability_name: String = "Unnamed Ability"
@export var description: String = ""
@export var target_mode: TargetMode = TargetMode.ENEMY
@export var animation_name: String = ""
@export var mana_cost: float = 0.0
@export var mana_restore: float = 0.0
@export var base_damage: float = 0.0
@export var stat_scaling: Dictionary = {
	"attack": 0.0,
	"defense": 0.0,
	"speed": 0.0,
	"mana": 0.0
}
@export var stat_bonus: Dictionary = {
	"attack": 0.0,
	"defense": 0.0,
	"speed": 0.0,
	"mana": 0.0
}

func calc_stat_scaling(stats: StatsComponent) -> float:
	var total = base_damage
	for stat in stat_scaling.keys():
		if stat_scaling[stat] > 0.0:
			total += stats.base_stats.get(stat, 0.0) * stat_scaling[stat]
	return total

func can_use(current_mana: float) -> bool:
	return current_mana >= mana_cost

# Returns which champions should become clickable targets for this ability.
# Override in subclasses for special targeting (e.g. self-only, all champions).
func get_valid_targets(attacker: Champion, player_champions: Array[Champion], all_champions: Array[Champion]) -> Array[Champion]:
	if target_mode == TargetMode.ALLY:
		return player_champions
	return all_champions.filter(func(c): return not player_champions.has(c))

# Full ability execution: walk, animate, apply effects, walk back.
# Override this for abilities that need a completely different sequence (e.g. Rest).
func apply(caster: Champion, target: Champion) -> void:
	await caster.walk_to(target.global_position)
	await caster.play_ability_animation(animation_name)
	_apply_effects(caster, target)
	await caster.walk_home()

# Override this to change what the ability does without changing the movement/animation sequence.
func _apply_effects(caster: Champion, target: Champion) -> void:
	caster.current_mana += mana_restore - mana_cost
	if base_damage > 0:
		target.health.take_damage(calc_stat_scaling(caster.stats))
	for stat in stat_bonus:
		if stat_bonus[stat] != 0:
			target.stats.base_stats[stat] += stat_bonus[stat]
