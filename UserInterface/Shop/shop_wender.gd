extends Node2D

@onready var left_arm: TextureRect = $Left_arm
@onready var right_arm_2: TextureRect = $Right_arm2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_local = get_local_mouse_position()
	var pivot_local = Vector2(right_arm_2.offset_left, right_arm_2.offset_top) + right_arm_2.pivot_offset
	var direction = mouse_local - pivot_local
	var angle = atan2(direction.y, direction.x)

	right_arm_2.rotation = clamp(angle, 0.0, PI / 2.0)
