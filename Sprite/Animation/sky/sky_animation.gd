extends Control

## Textures to pick from. Drag in as many cloud PNGs as you like.
## If empty the spawner does nothing.
@export var cloud_textures: Array[Texture2D] = [
	preload("uid://d25hd1w0qricw")
	]

## How many clouds are alive at once.
@export var cloud_count: int = 10

## Scale range for spawned clouds.
@export var min_scale: float = 0.3
@export var max_scale: float = 1.2

## Horizontal scroll speed range (pixels / second).
@export var min_speed: float = 15.0
@export var max_speed: float = 80.0

## Vertical band clouds spawn in (0 = top, 1 = bottom of the node).
@export var spawn_y_min: float = 0.05
@export var spawn_y_max: float = 0.55

## Opacity range for variety.
@export var min_opacity: float = 0.5
@export var max_opacity: float = 0.95

# ── internals ────────────────────────────────────────────────────────────────
var _clouds: Array[Sprite2D] = []


func _ready() -> void:
	if cloud_textures.is_empty():
		return
	for i in cloud_count:
		# Spread initial X across the whole width so they don't all start left.
		var x := randf_range(0.0, size.x)
		_spawn_cloud(x)


func _process(delta: float) -> void:
	for cloud in _clouds:
		cloud.position.x += cloud.get_meta("speed") * delta

		var half_w: float = cloud.texture.get_width() * cloud.scale.x * 0.5
		# Exited right edge → respawn on the left.
		if cloud.position.x - half_w > size.x:
			_reset_cloud(cloud, -half_w)
		# Exited left edge → respawn on the right.
		elif cloud.position.x + half_w < 0.0:
			_reset_cloud(cloud, size.x + half_w)


# ── helpers ───────────────────────────────────────────────────────────────────

func _spawn_cloud(x: float) -> void:
	var cloud := Sprite2D.new()
	add_child(cloud)
	_clouds.append(cloud)
	_init_cloud(cloud, x)


## Sets (or re-randomises) every property of a cloud Sprite2D.
func _init_cloud(cloud: Sprite2D, x: float) -> void:
	cloud.texture = cloud_textures[randi() % cloud_textures.size()]
	var s := randf_range(min_scale, max_scale)
	cloud.scale    = Vector2(s, s)
	cloud.position = Vector2(x, randf_range(spawn_y_min, spawn_y_max) * size.y)
	cloud.modulate = Color(1.0, 1.0, 1.0, randf_range(min_opacity, max_opacity))
	cloud.set_meta("speed", randf_range(min_speed, max_speed))


## Called when a cloud scrolls off-screen; re-randomises it on the right side.
func _reset_cloud(cloud: Sprite2D, new_x: float) -> void:
	_init_cloud(cloud, new_x)
