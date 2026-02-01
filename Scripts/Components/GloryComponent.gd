# Handles glory progression and arena win/loss conditions
class_name GloryComponent
extends Node

signal glory_changed(current: float)
signal arena_won
signal arena_lost

@export var starting_glory: float = 0.0
@export var min_glory: float = -10.0
@export var max_glory: float = 100.0

var current_glory: float = 0.0

func _ready() -> void:
	current_glory = starting_glory
	emit_signal("glory_changed", current_glory)

# -------------------
# Public API
# -------------------
func add_glory(amount: float) -> void:
	current_glory += amount
	emit_signal("glory_changed", current_glory)
	_check_arena_status()

func subtract_glory(amount: float) -> void:
	current_glory -= amount
	emit_signal("glory_changed", current_glory)
	_check_arena_status()

func set_glory(value: float) -> void:
	current_glory = value
	emit_signal("glory_changed", current_glory)
	_check_arena_status()

func has_won() -> bool:
	return current_glory >= max_glory

func has_lost() -> bool:
	return current_glory <= min_glory

func _check_arena_status() -> void:
	if has_won():
		emit_signal("arena_won")
	elif has_lost():
		emit_signal("arena_lost")
