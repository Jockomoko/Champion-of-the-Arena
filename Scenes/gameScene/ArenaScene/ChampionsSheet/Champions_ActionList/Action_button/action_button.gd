extends Control

signal ability_pressed(ability_name: String)

@onready var ability_icon: TextureRect = $TextureButton/HBoxContainer/Ability_icon
@onready var cost: AutoSizeLabel = $TextureButton/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Mana_cost
@onready var nameLabel: AutoSizeLabel = $TextureButton/HBoxContainer/MarginContainer/VBoxContainer/Name
@onready var texture_button: TextureButton = $TextureButton

var ability_name: String = ""

func set_button(icon: Texture2D, p_ability_name: String, mana_cost: int) -> void:
	ability_name = p_ability_name
	ability_icon.texture = icon
	nameLabel.text = p_ability_name
	cost.text = str(mana_cost)
	# Connect the actual button press
	texture_button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	ability_pressed.emit(ability_name)

# Called by ActionContainer to highlight/unhighlight
func set_selected(value: bool) -> void:
	texture_button.modulate = Color.YELLOW if value else Color.WHITE
