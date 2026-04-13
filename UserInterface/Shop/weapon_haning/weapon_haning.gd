extends Control

var item_id: String = ""

@onready var weapon: TextureRect = $Weapon

func set_weapon(item: Item, id: String) -> void:
	item_id = id
	weapon.texture = item.texture
