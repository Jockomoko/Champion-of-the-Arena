extends Control

@onready var champion: Champion = $SubViewportContainer/SubViewport/Champions
@onready var left_container: VBoxContainer = $TextureRect/LeftContainer
@onready var right_container: VBoxContainer = $TextureRect/RightContainer

signal go_left_hair_index()
signal go_Right_hair_index()
signal go_left_eye_index()
signal go_Right_eye_index()
signal go_left_mouth_index()
signal go_Right_mouth_index()
signal set_color_skin()

func set_apperance(apperance : Dictionary):
	champion.apply_appearance(apperance)


func _on_hair_button_left_pressed() -> void:
	emit_signal("go_left_hair_index")

func _on_eyes_button_left_pressed() -> void:
	emit_signal("go_left_eye_index")

func _on_mouth_button_left_pressed() -> void:
	emit_signal("go_left_mouth_index")

func _on_hair_button_right_pressed() -> void:
	emit_signal("go_Right_hair_index")

func _on_eyes_button_right_pressed() -> void:
	emit_signal("go_Right_eye_index")

func _on_mouth_button_right_pressed() -> void:
	emit_signal("go_Right_mouth_index")


func _on_color_button_pressed() -> void:
	emit_signal("set_color_skin")
