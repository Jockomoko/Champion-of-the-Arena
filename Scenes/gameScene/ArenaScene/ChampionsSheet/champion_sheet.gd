extends Control

const CHAMPION_STATS_CONTAINER = preload("uid://rk3vhw2cs1xl")
const defualt_image = preload("uid://dfu43kjmmua2x")

@onready var champions_bar: VBoxContainer = $TextureRect/Control/HBoxContainer/Champions_Bar
@onready var action_container: Control = $TextureRect/Control/HBoxContainer/VBoxContainer2/ActionContainer
@onready var waiting_label: AutoSizeLabel = $TextureRect/Control/HBoxContainer/VBoxContainer2/ActionContainer/waiting_lable

signal ability_selected(ability_name: String)

var selected_ability: String = ""

func _ready() -> void:
	waiting_label.hide()

func add_player_bar(max_health: int, max_mana: int) -> void:
	var container = CHAMPION_STATS_CONTAINER.instantiate()
	champions_bar.add_child(container)
	container.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.init(max_health, max_mana)

func show_ability_menu(abilities: Array[Ability]) -> void:
	if abilities.is_empty():
		push_warning("champion_sheet: no abilities to show")
		return
	waiting_label.hide()
	action_container.show()
	action_container.clear_abilities()
	for ability in abilities:
		if ability == null:
			push_warning("champion_sheet: skipping null ability in list")
			continue
		action_container.add_ability(ability.icon if ability.icon else defualt_image, ability.ability_name, ability.mana_cost)
	if not action_container.ability_selected.is_connected(_on_ability_selected):
		action_container.ability_selected.connect(_on_ability_selected)

func _on_ability_selected(ability_name: String) -> void:
	selected_ability = ability_name
	# Keep buttons visible so player can switch — just show hint
	waiting_label.show()
	waiting_label.text = "Select a target or choose another ability..."
	ability_selected.emit(ability_name)

func hide_ability_menu() -> void:
	action_container.clear_abilities()
	action_container.hide()
	waiting_label.hide()
	selected_ability = ""

func show_waiting(champion_name: String) -> void:
	action_container.hide()
	waiting_label.show()
	waiting_label.text = "Waiting for %s..." % champion_name
