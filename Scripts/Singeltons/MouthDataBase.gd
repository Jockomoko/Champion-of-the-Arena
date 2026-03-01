extends Node

var mouths: Dictionary[int, Mouth] = {}

func _ready() -> void:
	_register_mouth()

func _register_mouth() -> void:
	mouths[0] = Mouth.new()
	
func get_mouth(mouths_id: int) -> Hair:
	if not mouths.has(mouths_id):
		return
	return mouths.get(mouths_id)
