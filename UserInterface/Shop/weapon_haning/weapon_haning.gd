extends Control

var item_id: String = ""

@onready var weapon: Sprite2D = $Sprite2D
@onready var remote_transform: RemoteTransform2D = $Skeleton2D/Bone2D2/RemoteTransform2D

var _weapon_instance: Node = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(80, 160)

func set_weapon(item: Item, id: String) -> void:
	item_id = id
	if _weapon_instance:
		_weapon_instance.queue_free()
	_weapon_instance = item.item_scene.instantiate()
	add_child(_weapon_instance)
	_weapon_instance.position = weapon.position
	_weapon_instance.rotation = weapon.rotation
	_weapon_instance.scale = weapon.scale
	remote_transform.remote_path = remote_transform.get_path_to(_weapon_instance)
	weapon.hide()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_purchase()

func _try_purchase() -> void:
	var controller = Globals.MY_PLAYERCONTROLLER
	if controller == null:
		return
	var success = controller.buy_item(item_id)
	if success:
		_flash(Color(0.2, 1.0, 0.2))
	else:
		_flash(Color(1.0, 0.2, 0.2))

func _flash(color: Color) -> void:
	modulate = color
	await get_tree().create_timer(0.3).timeout
	modulate = Color.WHITE
