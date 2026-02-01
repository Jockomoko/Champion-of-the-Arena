# ItemDatabase.gd
extends Node
class_name ItemDatabase

# Dictionary to hold all items
var items: Dictionary = {}

func _ready():
	# Preload items
	items["iron_sword"] = preload("res://Scripts/Items/iron_sword.tres")

# Get an item by ID
func get_item(item_id: String):
	return items.get(item_id, null)
