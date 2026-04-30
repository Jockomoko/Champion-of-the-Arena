extends Node
class_name ItemDataBase

# item_id : Item
static var items: Dictionary[String, Item] = {}

static func _static_init() -> void:
	items["iron_sword"] = preload("res://Scripts/Resourcse/Items/Weapons/Sword/Iron_sword/iron_sword.tres")
	items["stick"] = preload("uid://bxplgsety7etc")
static func get_item(item_id: String) -> Item:
	return items.get(item_id)
