extends Control
@onready var mana_bar: ProgressBar = $TextureRect/VBoxContainer/ManaContainer/Mana_bar
@onready var health_bar: ProgressBar = $TextureRect/VBoxContainer/HealthContainer/Health_Bar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_health_max_value(value : int):
	health_bar.max_value = value

func set_health_value(value : int):
	health_bar.value = value

func set_mana_max_value(value : int):
	mana_bar.max_value = value

func set_mana_value(value : int):
	mana_bar.value = value
