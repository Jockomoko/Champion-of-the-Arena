extends Node2D

const CITY_SCENE = "res://Scenes/gameScene/CityScene/CityScene.tscn"

@export var item_ids: Array[String] = []

@onready var weapon_rack = $WeaponRack

func _ready() -> void:
	load_weapons()

func load_weapons() -> void:
	for item_id in item_ids:
		weapon_rack.add_weapon(item_id)

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file(CITY_SCENE)
