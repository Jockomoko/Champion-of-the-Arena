extends Node2D
class_name Champion

@export var champion_name: String = "Unnamed"
@export var icon: Texture2D

# Components
@onready var stats: StatsComponent = $StatsComponent
@onready var health: HealthComponent = $HealthComponent
@onready var equipment: EquipmentComponent = $EquipmentComponent

func _ready():
	# Set health based on effective stats
	health.max_health = stats.get_health()
	health.current_health = health.max_health

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
