extends Control

const ACTION_BUTTON = preload("uid://d1uj7p2n8ud08")

@onready var v_box_container: VBoxContainer = $TextureRect/ScrollContainer/VBoxContainer

signal ability_selected(ability_name: String)

var selected_button = null

func add_ability(icon: Texture2D, ability_name: String, mana_cost: int) -> void:
	var action = ACTION_BUTTON.instantiate()
	v_box_container.add_child(action)
	action.set_button(icon, ability_name, mana_cost)
	action.ability_pressed.connect(_on_ability_pressed)

func _on_ability_pressed(ability_name: String) -> void:
	# Deselect previous button
	if selected_button != null:
		selected_button.set_selected(false)

	# Find and select the pressed button
	for child in v_box_container.get_children():
		if child.ability_name == ability_name:
			selected_button = child
			child.set_selected(true)
			break

	ability_selected.emit(ability_name)

func clear_abilities() -> void:
	selected_button = null
	for child in v_box_container.get_children():
		child.queue_free()

func deselect_all() -> void:
	selected_button = null
	for child in v_box_container.get_children():
		child.set_selected(false)
