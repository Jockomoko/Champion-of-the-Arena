class_name HealthComponent
extends Node

signal damaged(amount: float)
signal healed(amount: float)
signal died
signal revived
signal health_changed(current: float, max: float)

var max_health: float = 100.0:
	set(value):
		max_health = max(value, 1.0)
		current_health = clamp(current_health, 0.0, max_health)
		emit_signal("health_changed", current_health, max_health)

var current_health: float = 100.0:
	set(value):
		var was_dead := _is_dead
		current_health = clamp(value, 0.0, max_health)

		emit_signal("health_changed", current_health, max_health)

		if current_health <= 0.0 and not was_dead:
			_is_dead = true
			emit_signal("died")

var _is_dead: bool = false

func _ready():
	current_health = max_health

# -------------------
# Public API
# -------------------

func take_damage(amount: float) -> void:
	if amount <= 0 or _is_dead:
		return

	current_health -= amount
	emit_signal("damaged", amount)

func heal(amount: float) -> void:
	if amount <= 0:
		return

	current_health += amount
	emit_signal("healed", amount)

func revive(health_amount: float = -1.0) -> void:
	if not _is_dead:
		return

	_is_dead = false

	if health_amount < 0.0:
		current_health = max_health
	else:
		current_health = clamp(health_amount, 1.0, max_health)

	emit_signal("revived")

func is_dead() -> bool:
	return _is_dead
