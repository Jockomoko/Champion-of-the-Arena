extends Control

var item_id: String = ""

@onready var weapon: Sprite2D = $Sprite2D

func set_weapon(item: Item, id: String) -> void:
	item_id = id
	weapon.texture = item.texture
