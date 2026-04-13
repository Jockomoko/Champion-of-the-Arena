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
@export var mana_cost: int = 0
@export var mana_restore: int = 0
@export var base_damage: float = 0.0
@export var stat_scaling: Dictionary = {
	"attack": 0.0,
	"defense": 0.0,
	"speed": 0.0,
	"mana": 0.0
}
@export var stat_bonus: Dictionary = {
	"attack": 0,
	"defense": 0,
	"speed": 0,
	"mana": 0
}

func get_damage(stats: StatsComponent) -> float:
	var total = base_damage
	for stat in stat_scaling.keys():
		if stat_scaling[stat] > 0.0:
			total += stats.base_stats.get(stat, 0) * stat_scaling[stat]
	return total

func can_use(current_mana: int) -> bool:
	return current_mana >= mana_cost

# Returns which champions should become clickable targets for this ability.
# Override in subclasses for special targeting (e.g. self-only, all champions).
func get_valid_targets(player_champions: Array[Champion], all_champions: Array[Champion]) -> Array[Champion]:
	if target_mode == TargetMode.ALLY:
		return player_champions
	return all_champions.filter(func(c): return not player_champions.has(c))

# Override in subclasses — returns a Dictionary of effects to apply.
func apply(attacker: Champion, target: Champion) -> Dictionary:
	return {}
