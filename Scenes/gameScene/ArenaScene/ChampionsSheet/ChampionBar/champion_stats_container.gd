extends Control
@onready var health_bar: ProgressBar = $TextureRect/VBoxContainer/HealthContainer/Health_Bar
@onready var mana_bar: ProgressBar = $TextureRect/VBoxContainer/ManaContainer/Mana_bar


func init(health_max_value : int, mana_max_value : int):
	set_health_max_value(health_max_value)
	set_health_value(health_max_value)
	
	set_mana_max_value(mana_max_value)
	set_mana_value(mana_max_value)

func set_health_max_value(value : int):
	health_bar.max_value = value

func set_health_value(value : int):
	health_bar.value = value

func set_mana_max_value(value : int):
	mana_bar.max_value = value

func set_mana_value(value : int):
	mana_bar.value = value
