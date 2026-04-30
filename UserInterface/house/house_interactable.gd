@tool
extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var display_scene: PackedScene:
	set(value):
		display_scene = value
		if is_node_ready():
			_spawn_display()

signal pressed

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	var existing = get_node_or_null("Display")
	if existing == null:
		_spawn_display()
	else:
		_fit_textures(existing)
		_disable_display_mouse(existing)

func _spawn_display() -> void:
	if display_scene == null:
		return
	var existing = get_node_or_null("Display")
	if existing:
		existing.queue_free()
	var instance = display_scene.instantiate()
	instance.name = "Display"
	add_child(instance)
	_fit_textures(instance)
	_disable_display_mouse(instance)
	if Engine.is_editor_hint():
		instance.owner = get_tree().edited_scene_root

func _fit_textures(display: Node) -> void:
	for child in display.get_children():
		if child is TextureRect and child.texture != null and child.size == Vector2.ZERO:
			child.size = child.texture.get_size()

# Stop Display (and its children) from intercepting mouse events so that
# clicks/hovers fall through to this HouseInteractable's own hit testing.
func _disable_display_mouse(display: Node) -> void:
	if display is Control:
		(display as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in display.get_children():
		if child is Control:
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

func _has_point(point: Vector2) -> bool:
	var display = get_node_or_null("Display")
	if display == null:
		return false
	for child in display.get_children():
		if child is TextureRect and child.size != Vector2.ZERO:
			var local_rect := Rect2(child.get_global_position() - get_global_position(), child.size)
			if local_rect.has_point(point):
				return true
	return false

func _on_mouse_entered() -> void:
	modulate = Color(1.5, 1.5, 1.5)

func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			emit_signal("pressed")
			if animation_player.has_animation("press"):
				animation_player.play("press")
