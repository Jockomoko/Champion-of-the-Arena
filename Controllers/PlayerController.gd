extends Node
class_name PlayerController

@export var player_id: int = Globals.STEAM_ID
@export var player_name: String = Globals.STEAM_NAME

var glory := GloryComponent.new()
var inventory := InventoryComponent.new()
var team := TeamComponent.new()

signal player_won
signal player_lost

func _ready():
	team.TeamComponent()
	
	# React to glory changes
	glory.arena_won.connect(_on_arena_won)
	glory.arena_lost.connect(_on_arena_lost)

func _on_arena_won():
	player_won.emit()
	GameController.player_won(self)

func _on_arena_lost():
	player_lost.emit()
	GameController.player_lost(self)

# -------------------
# Menu actions
# -------------------

func buy_item(item_id: String):
	if inventory.can_afford(item_id):
		inventory.add_item(item_id)

func lose_match():
	glory.remove_glory(GameController.glory_loss)

func win_match():
	glory.add_glory(GameController.glory_gain)
