extends Node

var eyes: Dictionary[int, Eye] = {}

func _ready() -> void:
	_register_eye()

func _register_eye() -> void:
	eyes[0] = Eye.new()

func get_eye(eyes_id: int) -> Hair:
	if not eyes.has(eyes_id):
		return
	return eyes.get(eyes_id)
