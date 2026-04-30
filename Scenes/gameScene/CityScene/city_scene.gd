extends Node2D

const SHOP_SCENE = "res://Scenes/gameScene/ShopScene/Shop_scene.tscn"

@onready var shop: Control = $Weapon_smith
@onready var timer_bar: Control = $Timer
@onready var armory: Control = $Armory_smith


func _ready() -> void:
	GameController.on_city_scene_ready()
	timer_bar.timer(GameController.city_wait_time)
	GameController.countdown_updated.connect(_update_clock)
	shop.pressed.connect(_on_shop_pressed)
	armory.pressed.connect(_on_armory_pressed)

func _update_clock(time_left: int) -> void:
	timer_bar.set_time_value(time_left)

func _on_weapon_smith_pressed() -> void:
	get_tree().change_scene_to_file(SHOP_SCENE)

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file(SHOP_SCENE)

func _on_armory_pressed() -> void:
	get_tree().change_scene_to_file(SHOP_SCENE)
