extends Resource
class_name Ability

enum Type { MELEE, SPELL, REST }
const default_Icon = preload("uid://dfu43kjmmua2x")

@export var icon : Texture2D = default_Icon
@export var id: String = ""
@export var ability_name: String = "Unnamed Ability"
@export var description: String = ""
@export var type: Type = Type.MELEE
@export var mana_cost: int = 0
@export var mana_restore: int = 0
@export var base_damage: float = 0.0
@export var stat_scaling: Dictionary = {
	"attack": 0.0,
	"defense": 0.0,
	"speed": 0.0,
	"mana": 0.0
}

func get_damage(stats: StatsComponent) -> float:
	var total = base_damage
	for stat in stat_scaling.keys():
		if stat_scaling[stat] > 0.0:
			total += stats.base_stats.get(stat, 0) * stat_scaling[stat]
	return total

func can_use(current_mana: int) -> bool:
	return current_mana >= mana_cost
