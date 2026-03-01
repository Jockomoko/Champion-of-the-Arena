extends Control

@onready var ability_icon: TextureRect = $TextureButton/HBoxContainer/Ability_icon
@onready var cost: AutoSizeLabel = $TextureButton/HBoxContainer/MarginContainer/HBoxContainer/Mana_cost
@onready var nameLabel: AutoSizeLabel = $TextureButton/HBoxContainer/MarginContainer/VBoxContainer/Name

func set_button(icon : Texture2D, ability_name : String, mana_cost : int) :
	ability_icon.texture = icon
	nameLabel.text = str(ability_name)
	cost.text = str(mana_cost)
