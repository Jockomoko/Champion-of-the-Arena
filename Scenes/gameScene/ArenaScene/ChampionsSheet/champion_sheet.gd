extends Control

const CHAMPION_STATS_CONTAINER = preload("uid://rk3vhw2cs1xl")
const defualt_image = preload("uid://dfu43kjmmua2x")

@onready var champions_bar: VBoxContainer = $TextureRect/Control/HBoxContainer/Champions_Bar
@onready var action_container: Control = $TextureRect/Control/HBoxContainer/VBoxContainer2/ActionContainer
@onready var waiting_label: AutoSizeLabel = $TextureRect/Control/HBoxContainer/VBoxContainer2/ActionContainer/waiting_lable

signal ability_selected(ability_name: String)

var selected_ability: String = ""

func add_player_bar(champion: Champion) -> void:
	var container = CHAMPION_STATS_CONTAINER.instantiate()
	champions_bar.add_child(container)
	container.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.init(champion.get_max_health(), champion.get_max_mana())
	champion.health_changed.connect(func(current, _max): container.set_health_value(current))
	champion.mana_changed.connect(func(current, _max): container.set_mana_value(current))

func show_ability_menu(abilities: Array[Ability]) -> void:
	if abilities.is_empty():
		push_warning("champion_sheet: no abilities to show")
		return
	action_container.show()
	action_container.clear_abilities()
	
	# Disconnect any existing connections before reconnecting
	if action_container.ability_selected.is_connected(_on_ability_selected):
		action_container.ability_selected.disconnect(_on_ability_selected)
	
	for ability in abilities:
		if ability == null:
			push_warning("champion_sheet: skipping null ability in list")
			continue
		action_container.add_ability(ability.icon if ability.icon else defualt_image, ability.ability_name, ability.mana_cost)
	
	action_container.ability_selected.connect(_on_ability_selected)

func _on_ability_selected(ability_name: String) -> void:
	selected_ability = ability_name
	ability_selected.emit(ability_name)

func hide_ability_menu() -> void:
	action_container.clear_abilities()
	action_container.hide()
	selected_ability = ""