extends Node
class_name ItemDatabase

# item_id : Item
var items: Dictionary[String, Item] = {}

func _ready() -> void:
	_register_items()

func _register_items() -> void:
	items["iron_sword"] = preload("res://Scripts/Resourcse/iron_sword.tres")

func get_item(item_id: String) -> Item:
	return items.get(item_id)
