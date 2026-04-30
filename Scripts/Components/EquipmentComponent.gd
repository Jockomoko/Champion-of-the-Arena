extends Node
class_name EquipmentComponent

# ------------------------------
# Single source of truth for valid equipment slots
# ------------------------------
enum VALID_SLOTS { HELMET=1, SHIRT=2, PANTS=3, WEAPON=4, SHIELD=5 }

# Dictionary to store equipped items (slot_name -> Item or null)
var slots: Dictionary = {}

# Signal emitted when equipment changes
signal equipment_changed(slot_name: String, item)

# ------------------------------
# Initialization
# ------------------------------
func _init():
	for slot_name in VALID_SLOTS:
		slots[slot_name] = null

# ------------------------------
# Equip an item
# ------------------------------
func equip_item(slot_name: String, item) -> bool:
	if not slots.has(slot_name):
		push_error("Invalid slot: " + slot_name)
		return false

	slots[slot_name] = item
	emit_signal("equipment_changed", slot_name, item)
	return true

# ------------------------------
# Unequip an item
# ------------------------------
func unequip_item(slot_name: String) -> void:
	if slots.has(slot_name):
		slots[slot_name] = null
		emit_signal("equipment_changed", slot_name, null)

# ------------------------------
# Get item in a slot
# ------------------------------
func get_item(slot_name: String):
	return slots.get(slot_name, null)

# ------------------------------
# Get all equipped items
# ------------------------------
func get_all_items() -> Array:
	return slots.values()
