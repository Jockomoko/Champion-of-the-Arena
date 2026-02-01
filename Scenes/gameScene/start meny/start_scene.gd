extends Node2D

@onready var texture_button: TextureButton = $TextureButton

func _ready() -> void:
	pass # Replace with function body.


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Steam_lobby.tscn")


func _on_texture_button_mouse_entered() -> void:
	texture_button.set_rotation(0.1)


func _on_texture_button_mouse_exited() -> void:
	texture_button.set_rotation(0.0)
