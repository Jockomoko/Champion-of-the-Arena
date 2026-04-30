extends Control

const ITEM_SLOT_SCENE = preload("res://UserInterface/Inventory/ItemSlot.tscn")
const CHAMPION_CARD_SCENE = preload("res://UserInterface/Inventory/ChampionCard.tscn")

@onready var item_grid: GridContainer = $MarginContainer/HBox/InventoryPanel/VBox/ScrollContainer/ItemGrid
@onready var champions_container: HBoxContainer = $MarginContainer/HBox/ChampionsContainer
@onready var tooltip: Panel = $Tooltip
@onready var tooltip_name: Label = $Tooltip/VBox/ItemName
@onready var tooltip_desc: Label = $Tooltip/VBox/Description
@onready var tooltip_stats: Label = $Tooltip/VBox/Stats
@onready var close_button: Button = $CloseButton

func _ready() -> void:
	tooltip.hide()
	close_button.pressed.connect(_on_close_pressed)
	_load_inventory()
	_load_champions()

func _load_inventory() -> void:
	var controller := Globals.MY_PLAYERCONTROLLER
	if controller == null:
		return
	for child in item_grid.get_children():
		child.queue_free()
	for item_id in controller.inventory.items:
		var amount := controller.inventory.get_amount(item_id)
		var slot: Panel = ITEM_SLOT_SCENE.instantiate()
		item_grid.add_child(slot)
		slot.setup(item_id, amount)
		slot.slot_hovered.connect(show_tooltip)
		slot.slot_unhovered.connect(hide_tooltip)
	if not controller.inventory.inventory_changed.is_connected(_load_inventory):
		controller.inventory.inventory_changed.connect(_load_inventory)

func _load_champions() -> void:
	var controller := Globals.MY_PLAYERCONTROLLER
	if controller == null:
		return
	for champion in controller.team.champions:
		var card: Panel = CHAMPION_CARD_SCENE.instantiate()
		champions_container.add_child(card)
		card.setup(champion)
		card.item_equipped.connect(_on_item_equipped)

func _on_item_equipped(_champion: Champion, _slot_name: String, item_id: String) -> void:
	var controller := Globals.MY_PLAYERCONTROLLER
	if controller:
		controller.inventory.remove_item(item_id)

func _process(_delta: float) -> void:
	if tooltip.visible:
		tooltip.global_position = get_global_mouse_position() + Vector2(16, 16)

func show_tooltip(item_id: String) -> void:
	var item := ItemDataBase.get_item(item_id)
	if item == null:
		return
	tooltip_name.text = item.name
	tooltip_desc.text = item.description
	var stats_text := ""
	for stat in item.modifiers:
		if item.modifiers[stat] != 1.0:
			stats_text += "%s: x%.2f\n" % [stat.capitalize(), item.modifiers[stat]]
	tooltip_stats.text = stats_text.strip_edges()
	tooltip.show()

func hide_tooltip() -> void:
	tooltip.hide()

func _on_close_pressed() -> void:
	for card in champions_container.get_children():
		if card.has_method("release_champion"):
			card.release_champion()
	queue_free()
