extends Node2D

@onready var left_arm: TextureRect = $Left_arm
@onready var right_arm_2: TextureRect = $Right_arm2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_local = to_local(get_global_mouse_position())
	var pivot_local = right_arm_2.position + right_arm_2.pivot_offset
	var direction = mouse_local - pivot_local
	var angle = atan2(direction.y, direction.x)
	right_arm_2.rotation = clamp(angle, 0.0, PI / 2.0)
