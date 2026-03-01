extends Node

var hairs: Dictionary[int, Hair] = {}

func _ready() -> void:
	_register_hairs()

func _register_hairs() -> void:
	hairs[0] = Hair.new()
	hairs[1] = preload("uid://cxub6i8taknt6")

func get_hair(hair_id: int) -> Hair:
	if not hairs.has(hair_id):
		return
	return hairs.get(hair_id)
