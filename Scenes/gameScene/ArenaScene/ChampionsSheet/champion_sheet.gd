extends Control
const CHAMPION_STATS_CONTAINER = preload("uid://rk3vhw2cs1xl")

@onready var champions_bar: VBoxContainer = $TextureRect/Control/HBoxContainer/Champions_Bar

func add_player_bar(max_health : int, max_mana : int) :
	var container = CHAMPION_STATS_CONTAINER.instantiate()
	champions_bar.add_child(container)
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.init(max_health, max_mana)
