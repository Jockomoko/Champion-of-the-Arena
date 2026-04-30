extends Node2D
class_name Champion

var champion_name: String = "Unnamed"
var combat_id: String = ""
var icon: Texture2D
var home_position: Vector2 = Vector2.ZERO

@onready var turn_icon: Node2D = $turn_icon
@onready var select_icon: Node2D = $select_icon
@onready var anim_player: AnimationPlayer = $AnimationPlayer


@onready var head_sprite: Sprite2D = $body/Head
@onready var left_arm: Sprite2D = $body/LeftArm
@onready var body_sprite: Sprite2D = $body/Body_sprite
@onready var right_arm: Sprite2D = $body/RightArm
@onready var left_leg: Sprite2D = $body/LeftLeg
@onready var right_leg: Sprite2D = $body/RightLeg
@onready var area: Area2D = $Area2D

@onready var hair: Sprite2D = $body/Head/Hair
@onready var mouth: Sprite2D = $body/Head/Mouth
@onready var eyes: Sprite2D = $body/Head/Eyes

signal champion_clicked(champion: Champion)
signal champion_hovered(champion: Champion)
signal champion_unhovered(champion: Champion)
signal health_changed(current: float, max_val: float)
signal mana_changed(current: float, max_val: float)
var is_clickable: bool = false
var _is_hovered: bool = false
var _default_opacity: float = 1.0

var current_mana: float = 0.0:
	set(value):
		current_mana = clampf(value, 0.0, get_max_mana())
		mana_changed.emit(current_mana, get_max_mana())
# Components
var stats := StatsComponent.new()
var health:= HealthComponent.new()
var equipment:= EquipmentComponent.new()
var abilities := AbilityComponent.new()
var appearance:= AppearanceComponent.new()

func _ready():
	if home_position != Vector2.ZERO:
		position = home_position
	_default_opacity = modulate.a
	turn_icon.hide()
	select_icon.hide()

	# Set health and mana based on effective stats
	health.max_health = stats.get_health() * 10
	health.current_health = health.max_health
	current_mana = get_max_mana()

	# Apply equipment bonuses
	_apply_equipment_modifiers()

	# Connect health signals
	health.damaged.connect(_on_damaged)
	health.healed.connect(_on_healed)
	health.died.connect(_on_died)
	health.revived.connect(_on_revived)
	health.health_changed.connect(_on_health_changed)
	
	# input_event on Area2D can be blocked by Control nodes; use _input + physics query instead
	
	# React to equipment changes
	equipment.equipment_changed.connect(_on_equipment_changed)

# Apply all equipped items to stats and health
func _apply_equipment_modifiers() -> void:
	for slot_item in equipment.get_all_items():
		if slot_item:
			for stat_name in slot_item.modifiers.keys():
				match stat_name:
					"attack", "defense", "speed", "mana":
						stats.apply_modifier(stat_name, slot_item.modifiers[stat_name])
					"health":
						health.max_health += slot_item.modifiers[stat_name]
						health.current_health += slot_item.modifiers[stat_name]

# Handle equipment changes at runtime
func _on_equipment_changed(slot_name: String, item) -> void:
	print("%s slot changed: %s" % [slot_name, str(item)])
	# Reset stats to base before reapplying equipment
	stats.modifiers = {
		"attack": 1.0,
		"defense": 1.0,
		"health": 1.0,
		"speed": 1.0,
		"mana": 1.0
	}
	health.max_health = stats.get_health() * 10
	health.current_health = health.max_health
	_apply_equipment_modifiers()
	_sync_abilities()

func _sync_abilities() -> void:
	abilities.equipped_ability_ids.clear()
	for slot_item in equipment.get_all_items():
		if slot_item and slot_item.get("ability_name", "") != "":
			abilities.equip_ability(slot_item.get("ability_name"))

# Health signal handlers
func _on_damaged(amount: float) -> void:
	print("%s took %f damage!" % [champion_name, amount])

func _on_healed(amount: float) -> void:
	print("%s healed %f HP!" % [champion_name, amount])

func _on_died() -> void:
	print("%s has died!" % champion_name)
	hide()

func _on_revived() -> void:
	print("%s has been revived!" % champion_name)

func _on_health_changed(current: float, max: float) -> void:
	print("%s HP: %f / %f" % [champion_name, current, max])
	health_changed.emit(current, max)
	
func get_max_health() -> float:
	return health.max_health

func get_max_mana() -> float:
	return stats.get_mana() * 10.0

func get_all_stats() -> Dictionary :
	return stats.base_stats

func set_stat(stat_name: String, stat_value: float) -> void:
	stats.base_stats[stat_name] = stat_value

func get_dictionary() -> Dictionary:
	return {
		"name": champion_name,
		"stats": stats.base_stats.duplicate(),
		"appearance": appearance.to_dict(),
		"abilities": abilities.get_available_abilities()
	}

func apply_appearance(new_appearance: Dictionary) -> void:
	if not is_inside_tree():
		await tree_entered
	
	print("appearance keys: ", new_appearance.keys())
	
	var body_color := Color(new_appearance["body_color"])
	var hair_color := Color(new_appearance["hair_color"])
	
	hair.self_modulate = hair_color
	head_sprite.self_modulate = body_color
	right_leg.self_modulate = body_color
	left_leg.self_modulate = body_color
	right_arm.self_modulate = body_color
	body_sprite.self_modulate = body_color
	left_arm.self_modulate = body_color
	
	var new_hair = HairDataBase.get_hair(new_appearance["hair_id"])
	var new_eye = EyeDataBase.get_eye(new_appearance["eye_id"])
	var new_mouth = MouthDataBase.get_mouth(new_appearance["mouth_id"])
	if new_hair:
		hair.texture = new_hair.icon
	if new_eye:
		eyes.texture = new_eye.icon
	if new_mouth:
		mouth.texture = new_mouth.icon

func set_clickable(value: bool) -> void:
	is_clickable = value and health.is_alive()
	select_icon.visible = is_clickable

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_check_hover()
		return
	if not is_clickable:
		return
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results = space_state.intersect_point(query)
	for result in results:
		if result["collider"] == area:
			get_viewport().set_input_as_handled()
			champion_clicked.emit(self)
			return

# Called by _input() every time the mouse moves (InputEventMouseMotion).
# We can't use Area2D.mouse_entered/mouse_exited signals here because those
# signals are blocked when a Control node sits on top of the champion in the
# scene (e.g. the ability sheet UI). Instead we manually do a physics point
# query each frame the mouse moves, check if the Area2D collider is under the
# cursor, and emit champion_hovered / champion_unhovered ourselves so the rest
# of the game can react regardless of what UI is on top.
func _check_hover() -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var results = space_state.intersect_point(query)
	var mouse_over := false
	for result in results:
		if result["collider"] == area:
			mouse_over = true
			break
	if mouse_over and not _is_hovered:
		_is_hovered = true
		modulate.a = 250.0 / 255.0
		champion_hovered.emit(self)
	elif not mouse_over and _is_hovered:
		_is_hovered = false
		modulate.a = _default_opacity
		champion_unhovered.emit(self)

func start_turn():
	turn_icon.show()

func end_turn():
	turn_icon.hide()

# Walks toward target_pos, stopping just before it. Awaitable.
func walk_to(target_pos: Vector2) -> void:
	var direction = (target_pos - global_position).normalized()
	var stop_pos = target_pos - direction * 100.0
	var duration = global_position.distance_to(stop_pos) / 400.0
	anim_player.play("Walking")
	var tween = create_tween()
	tween.tween_property(self, "global_position", stop_pos, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	anim_player.play("Idle")

# Walks back to the spawn position. Awaitable.
func walk_home() -> void:
	print("walk_home %s from=%s to home=%s" % [name, global_position, home_position])
	var duration = global_position.distance_to(home_position) / 400.0
	anim_player.play("Walking")
	var tween = create_tween()
	tween.tween_property(self, "global_position", home_position, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	anim_player.play("Idle")

# Plays the given animation then returns to Idle. Awaitable.
func play_ability_animation(anim_name: String) -> void:
	if anim_name != "" and anim_player.has_animation(anim_name):
		anim_player.play(anim_name)
		await anim_player.animation_finished
	anim_player.play("Idle")
