extends Panel

const EQUIP_SLOT_SCENE = preload("res://UserInterface/Inventory/EquipSlot.tscn")

signal item_equipped(champion: Champion, slot_name: String, item_id: String)

var champion: Champion = null

@onready var name_label: Label = $VBox/NameLabel
@onready var viewport: SubViewport = $VBox/ViewportRow/SubViewportContainer/SubViewport
@onready var equip_slots_container: VBoxContainer = $VBox/ViewportRow/EquipSlots
@onready var stats_grid: GridContainer = $VBox/StatsPanel/StatsGrid

func setup(champ: Champion) -> void:
	champion = champ
	name_label.text = champ.champion_name

	viewport.add_child(champ)
	champ.position = Vector2(100, 230)
	champ.apply_appearance(champ.appearance.to_dict())

	_build_equip_slots()
	_refresh_stats()

func release_champion() -> void:
	if champion and is_instance_valid(champion) and champion.get_parent() == viewport:
		viewport.remove_child(champion)

func _build_equip_slots() -> void:
	for slot_name in EquipmentComponent.VALID_SLOTS:
		var slot_index: int = EquipmentComponent.VALID_SLOTS[slot_name]
		var slot: Panel = EQUIP_SLOT_SCENE.instantiate()
		equip_slots_container.add_child(slot)
		slot.setup(slot_name, slot_index)
		slot.refresh(champion)
		slot.item_equipped.connect(_on_item_equipped)

func _on_item_equipped(slot_name: String, item_id: String) -> void:
	var item = ItemDataBase.get_item(item_id)
	if item == null:
		return
	champion.equipment.equip_item(slot_name, item)
	_refresh_stats()
	item_equipped.emit(champion, slot_name, item_id)

func _refresh_stats() -> void:
	for child in stats_grid.get_children():
		child.queue_free()
	for stat_name in champion.stats.base_stats.keys():
		var name_lbl := Label.new()
		name_lbl.text = stat_name.capitalize() + ":"
		stats_grid.add_child(name_lbl)
		var val_lbl := Label.new()
		val_lbl.text = str(int(champion.stats.get_stat(stat_name)))
		stats_grid.add_child(val_lbl)
