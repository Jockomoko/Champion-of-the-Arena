extends Node

var mouths: Dictionary[int, Mouth] = {}

func _ready() -> void:
	_register_mouth()

func _register_mouth() -> void:
	mouths[0] = Mouth.new()
	mouths[1] = preload("uid://b721kn7hpdelo")
	mouths[2] = preload("uid://chuycv1biitd5")
	
func get_mouth(mouths_id: int) -> Mouth:
	if not mouths.has(mouths_id):
		return
	return mouths.get(mouths_id)
