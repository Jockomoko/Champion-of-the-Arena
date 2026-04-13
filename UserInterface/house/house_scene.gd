@tool
extends Control

@onready var house: TextureButton = $TextureButton

@export var texture: Texture2D:
	set(value):
		texture = value
		# Update immediately in the editor when the value changes in the inspector
		if is_node_ready():
			house.texture_normal = texture

signal pressed

func _ready() -> void:
	house.texture_normal = texture

func _on_texture_button_pressed() -> void:
	emit_signal("pressed")


func _on_texture_button_mouse_exited() -> void:
	house.modulate = Color(1, 1, 1)

func _on_texture_button_mouse_entered() -> void:
	house.modulate = Color(1.5, 1.5, 1.5)
