extends Control

const WeaponHaning = preload("res://UserInterface/Shop/weapon_haning/weapon_haning.tscn")

@onready var hbox: HBoxContainer = $HBoxContainer

func add_weapon(item_id: String) -> void:
	var item = ItemDataBase.get_item(item_id)
	if item == null:
		return
	if _weapon_exists(item_id):
		return
	var haning = WeaponHaning.instantiate()
	hbox.add_child(haning)
	haning.set_weapon(item, item_id)

func _weapon_exists(item_id: String) -> bool:
	for child in hbox.get_children():
		if child.has_method("set_weapon") and child.get("item_id") == item_id:
			return true
	return false
