extends Panel

signal slot_hovered(item_id: String)
signal slot_unhovered

var item_id: String = ""

@onready var icon: TextureRect = $Icon
@onready var amount_label: Label = $AmountLabel

func _ready() -> void:
	mouse_entered.connect(func(): slot_hovered.emit(item_id))
	mouse_exited.connect(func(): slot_unhovered.emit())

func setup(id: String, amount: int) -> void:
	item_id = id
	var item = ItemDataBase.get_item(id)
	if item == null:
		return
	icon.texture = item.icon
	amount_label.text = "x%d" % amount if amount > 1 else ""

func _get_drag_data(_pos: Vector2) -> Variant:
	if item_id == "":
		return null
	var preview := TextureRect.new()
	preview.texture = icon.texture
	preview.custom_minimum_size = Vector2(48, 48)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)
	return {"type": "item", "item_id": item_id}
