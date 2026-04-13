extends Node2D

@onready var weapon_rack = $WeaponRack

func _ready() -> void:
	load_weapons()

func load_weapons() -> void:
	for item_id in GameController.shop_weapon_ids:
		weapon_rack.add_weapon(item_id)
