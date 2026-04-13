extends Node2D

const SHOP_SCENE = "res://Scenes/gameScene/ShopScene/Shop_scene.tscn"

@onready var shop: Control = $Weapon_smith
@onready var timer_bar: Control = $Timer

func _ready() -> void:
	GameController.on_city_scene_ready()
	timer_bar.timer(GameController.city_wait_time)
	GameController.countdown_updated.connect(_update_clock)
	Steam.lobby_data_update.connect(_on_lobby_data_update)
	shop.pressed.connect(_on_shop_pressed)

func _on_lobby_data_update(success, lobby_id, member_id):
	if lobby_id == Globals.LOBBY_ID:
		GameController.on_lobby_data_updated()

func _update_clock(time_left: int) -> void:
	timer_bar.set_time_value(time_left)

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file(SHOP_SCENE)
