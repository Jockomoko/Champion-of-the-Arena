@tool
extends Node2D

@export var texture: Texture2D :
	set(value):
		texture = value
		if is_node_ready():
			sprite.texture = value

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.texture = texture
	if Engine.is_editor_hint():
		return
	_start_bounce()
	_start_flip()

# Moves the sprite up and down continuously with a smooth sine curve.
func _start_bounce() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -12.0, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", 0.0, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

# Every ~2 seconds squeezes scale.x to 0 then expands it mirrored,
# waits, then squeezes back and expands to normal — giving a flip effect.
func _start_flip() -> void:
	var tween = create_tween().set_loops()
	tween.tween_interval(2.0)
	tween.tween_property(sprite, "scale:x", 0.0, 0.08)
	tween.tween_property(sprite, "scale:x", -1.0, 0.08)
	tween.tween_interval(2.0)
	tween.tween_property(sprite, "scale:x", 0.0, 0.08)
	tween.tween_property(sprite, "scale:x", 1.0, 0.08)
