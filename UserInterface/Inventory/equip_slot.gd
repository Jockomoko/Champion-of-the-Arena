extends Panel

signal item_equipped(slot_name: String, item_id: String)

var slot_name: String = ""
var slot_index: int = 0

@onready var slot_label: Label = $VBox/SlotLabel
@onready var icon: TextureRect = $VBox/Icon

func setup(s_name: String, s_index: int) -> void:
	slot_name = s_name
	slot_index = s_index
	slot_label.text = s_name.capitalize()

func refresh(champion: Champion) -> void:
	var equipped = champion.equipment.get_item(slot_name)
	icon.texture = equipped.icon if equipped else null

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.get("type") == "item"):
		return false
	var item = ItemDataBase.get_item(data["item_id"])
	if item == null:
		return false
	return int(item.validSlotIndex) == slot_index

func _drop_data(_pos: Vector2, data: Variant) -> void:
	var item_id: String = data["item_id"]
	var item = ItemDataBase.get_item(item_id)
	if item:
		icon.texture = item.icon
	item_equipped.emit(slot_name, item_id)
