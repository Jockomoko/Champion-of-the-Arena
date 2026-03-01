extends Control

const ACTION_BUTTON = preload("uid://d1uj7p2n8ud08")

@onready var v_box_container: VBoxContainer = $TextureRect/ScrollContainer/VBoxContainer

func add_ability(icon : Texture2D, ability_name : String, mana_cost : int) :
	var action = ACTION_BUTTON.instantiate()
	action.set_button(icon, ability_name, mana_cost)
	v_box_container.add_child(action)
