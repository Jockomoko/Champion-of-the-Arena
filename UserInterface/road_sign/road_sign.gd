extends TextureButton

@export var label_text: String = "Button"

@onready var label: Label = $AutoSizeLabel

func _ready() -> void:
	label.text = label_text

func _on_mouse_entered() -> void:
	_rotate_sign(0.1)

func _on_mouse_exited() -> void:
	_rotate_sign(0.0)

func _rotate_sign(angle: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", angle, 0.15)
