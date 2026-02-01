extends Node
class_name InventoryComponent

var items : Item = []

signal inventory_changed

func add_item(item_id: String, amount: int = 1):
	items[item_id] = items.get(item_id, 0) + amount
	inventory_changed.emit()

func remove_item(item_id: String, amount: int = 1):
	if not items.has(item_id):
		return
	items[item_id] -= amount
	if items[item_id] <= 0:
		items.erase(item_id)
	inventory_changed.emit()

func has_item(item_id: String) -> bool:
	return items.has(item_id)

func can_afford(_item_id: String) -> bool:
	# Hook this into glory/currency later
	return true
