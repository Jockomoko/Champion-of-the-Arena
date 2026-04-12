extends Control

@onready var label: Label = $TextureRect/HBoxContainer/AutoSizeLabel


func _ready() -> void:
	var controller: PlayerController = Globals.MY_PLAYERCONTROLLER
	if controller == null:
		controller = await Globals.player_controller_ready

	controller.wallet.money_changed.connect(_on_money_changed)
	_on_money_changed(controller.wallet.money)


func _on_money_changed(new_amount: int) -> void:
	label.text = str(new_amount)
