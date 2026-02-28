extends Node
class_name PlayerController

var player_id : int
var player_name : String

var glory := GloryComponent.new()
var inventory := InventoryComponent.new()
var team := TeamComponent.new()

signal player_won
signal player_lost


func _ready():
	
	player_id = Globals.STEAM_ID
	player_name = Globals.STEAM_NAME
	team.TeamComponent()

	# Register into Globals
	_register_controller()

	# React to glory changes
	glory.arena_won.connect(_on_arena_won)
	glory.arena_lost.connect(_on_arena_lost)


# =====================================
# GLOBAL REGISTRATION
# =====================================
func _register_controller():
	if Globals.LOBBY_MEMBERS.has(player_id):
		Globals.LOBBY_MEMBERS[player_id]["controller"] = self


# =====================================
# ARENA RESULTS
# =====================================
func _on_arena_won():
	player_won.emit()
	GameController.player_won(self)

func _on_arena_lost():
	player_lost.emit()
	GameController.player_lost(self)


# =====================================
# MENU ACTIONS
# =====================================
func buy_item(item_id: String):
	if inventory.can_afford(item_id):
		inventory.add_item(item_id)

func lose_match():
	glory.remove_glory(GameController.glory_loss)

func win_match():
	glory.add_glory(GameController.glory_gain)
	
func get_champions_team_data() -> Array:
	return team.get_team_data()
