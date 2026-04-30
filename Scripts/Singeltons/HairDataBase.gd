extends Node

var hairs: Dictionary[int, Hair] = {}

func _ready() -> void:
	_register_hairs()

func _register_hairs() -> void:
	hairs[0] = Hair.new()
	hairs[1] = preload("uid://cd87ggcs4f70l")
	hairs[2] = preload("uid://bd2orft261g53")
	
func get_hair(hair_id: int) -> Hair:
	if not hairs.has(hair_id):
		return null
	return hairs.get(hair_id)
