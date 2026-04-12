extends Control

signal ability_pressed(ability_name: String)

@onready var ability_icon: TextureRect = $TextureButton/HBoxContainer/Ability_icon
@onready var cost: AutoSizeLabel = $TextureButton/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Mana_cost
@onready var nameLabel: AutoSizeLabel = $TextureButton/HBoxContainer/MarginContainer/VBoxContainer/Name
@onready var texture_button: TextureButton = $TextureButton

var ability_name: String = ""

func _ready() -> void:
	texture_button.mouse_entered.connect(_on_mouse_entered)
	texture_button.mouse_exited.connect(_on_mouse_exited)

func set_button(icon: Texture2D, p_ability_name: String, mana_cost: int) -> void:
	ability_name = p_ability_name
	ability_icon.texture = icon
	nameLabel.text = p_ability_name
	cost.text = str(mana_cost)
	texture_button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	ability_pressed.emit(ability_name)

func _on_mouse_entered() -> void:
	_rotate_button(0.1)

func _on_mouse_exited() -> void:
	_rotate_button(0.0)

func _rotate_button(angle: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(texture_button, "rotation", angle, 0.15)

# Called by ActionContainer to highlight/unhighlight
func set_selected(value: bool) -> void:
	texture_button.modulate = Color(0.6, 0.6, 0.6) if value else Color.WHITE
