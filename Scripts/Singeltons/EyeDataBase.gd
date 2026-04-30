extends Node

var eyes: Dictionary[int, Eye] = {}

func _ready() -> void:
	_register_eye()

func _register_eye() -> void:
	eyes[0] = Eye.new()
	eyes[1] = preload("uid://4ootlxyo0r7n")
	eyes[2] = preload("uid://djsf3ollen4xj")
func get_eye(eyes_id: int) -> Eye:
	if not eyes.has(eyes_id):
		return null
	return eyes.get(eyes_id)
