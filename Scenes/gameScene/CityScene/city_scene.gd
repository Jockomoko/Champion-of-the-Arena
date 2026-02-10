extends Node2D
@onready var smith_btn: TextureButton = $Smith
@onready var church_btn: TextureButton = $Church
@onready var arena_btn: TextureButton = $Arena
var base_color = Color(1, 1, 1)
var hover_color = Color(2.432, 2.432, 2.432, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




######################
# Mouse Hover buttons#
######################

func _on_arena_mouse_entered() -> void:
	arena_btn.modulate = hover_color

func _on_arena_mouse_exited() -> void:
	arena_btn.modulate = base_color

func _on_arena_pressed() -> void:
	get_tree().quit()


func _on_smith_mouse_entered() -> void:
	smith_btn.modulate = hover_color


func _on_smith_mouse_exited() -> void:
	smith_btn.modulate = base_color


func _on_church_mouse_exited() -> void:
	church_btn.modulate = base_color


func _on_church_mouse_entered() -> void:
	church_btn.modulate = hover_color
