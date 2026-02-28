extends Node2D
@onready var smith_btn: TextureButton = $Smith
@onready var church_btn: TextureButton = $Church
@onready var arena_btn: TextureButton = $Arena
@onready var timer_Bar: Control = $Timer

var base_color = Color(1, 1, 1)
var hover_color = Color(2.432, 2.432, 2.432, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameController._on_city_scene_loaded()
	timer_Bar.timer(GameController.city_wait_time)
	GameController.countdown_updated.connect(_update_clock)
	Steam.lobby_data_update.connect(_on_lobby_data_update)

func _on_lobby_data_update(success, lobby_id, member_id):
	if lobby_id == Globals.LOBBY_ID:
		GameController.on_lobby_data_updated()

func _update_clock(time_left:int):
	timer_Bar.set_time_value(time_left)

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
