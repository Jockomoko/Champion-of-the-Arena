extends Node2D
class_name Champion

var champion_name: String = "Unnamed"
var icon: Texture2D
@onready var hair: Sprite2D = $body/Head/Hair
@onready var head_sprite: Sprite2D = $body/Head
@onready var left_arm: Sprite2D = $body/LeftArm
@onready var body_sprite: Sprite2D = $body/Body_sprite
@onready var right_arm: Sprite2D = $body/RightArm
@onready var left_leg: Sprite2D = $body/LeftLeg
@onready var right_leg: Sprite2D = $body/RightLeg


# Components
var stats := StatsComponent.new()
var health:= HealthComponent.new()
var equipment:= EquipmentComponent.new()
var abilities := AbilityComponent.new()
var appearance:= AppearanceComponent.new()

func _ready():
	# Set health based on effective stats
	health.max_health = get_max_health()
	health.current_health = get_max_health()

	# Apply equipment bonuses
	_apply_equipment_modifiers()

	# Connect health signals
	health.damaged.connect(_on_damaged)
	health.healed.connect(_on_healed)
	health.died.connect(_on_died)
	health.revived.connect(_on_revived)
	health.health_changed.connect(_on_health_changed)

	# React to equipment changes
	equipment.equipment_changed.connect(_on_equipment_changed)

# Apply all equipped items to stats and health
func _apply_equipment_modifiers() -> void:
	for slot_item in equipment.get_all_items():
		if slot_item:
			for stat_name in slot_item.modifiers.keys():
				match stat_name:
					"attack", "defense", "speed", "mana":
						stats.apply_modifier(stat_name, slot_item.modifiers[stat_name])
					"health":
						health.max_health += slot_item.modifiers[stat_name]
						health.current_health += slot_item.modifiers[stat_name]

# Handle equipment changes at runtime
func _on_equipment_changed(slot_name: String, item) -> void:
	print("%s slot changed: %s" % [slot_name, str(item)])
	# Reset stats to base before reapplying equipment
	stats.modifiers = {
		"attack": 1.0,
		"defense": 1.0,
		"health": 1.0,
		"speed": 1.0,
		"mana": 1.0
	}
	health.current_health = stats.get_health()
	_apply_equipment_modifiers()
	_sync_abilities()

func _sync_abilities() -> void:
	abilities.equipped_ability_ids.clear()
	for slot_item in equipment.get_all_items():
		if slot_item and slot_item.get("ability_name", "") != "":
			abilities.equip_ability(slot_item.ability_name)

# Health signal handlers
func _on_damaged(amount: float) -> void:
	print("%s took %f damage!" % [champion_name, amount])

func _on_healed(amount: float) -> void:
	print("%s healed %f HP!" % [champion_name, amount])

func _on_died() -> void:
	print("%s has died!" % champion_name)

func _on_revived() -> void:
	print("%s has been revived!" % champion_name)

func _on_health_changed(current: float, max: float) -> void:
	print("%s HP: %f / %f" % [champion_name, current, max])
	
func get_max_health() -> int:
	var stats_bonus = stats.get_health() * 10
	return health.max_health + stats_bonus

func get_max_mana() -> int:
	return stats.get_mana() * 10

func get_all_stats() -> Dictionary :
	return stats.base_stats

func set_stat(stat_name : String, stat_value : int) :
	stats.base_stats[stat_name] = stat_value

func get_dictionary() -> Dictionary:
	return {
		"name": name,
		"stats": stats.base_stats.duplicate(),
		"appearance": appearance.to_dict(),
		"abilities": abilities.get_available_abilities()
	}

func apply_appearance(new_appearance: AppearanceComponent) -> void:
	if not is_node_ready():
		await ready
	hair.modulate = new_appearance.hair_color
	head_sprite.modulate = new_appearance.body_color
	right_leg.modulate = new_appearance.body_color
	left_leg.modulate = new_appearance.body_color
	right_arm.modulate = new_appearance.body_color
	body_sprite.modulate = new_appearance.body_color
	left_arm.modulate = new_appearance.body_color
	var new_hair = HairDataBase.get_hair(new_appearance.hair_id)
	hair.texture = new_hair.icon
