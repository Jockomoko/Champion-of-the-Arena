extends Node
class_name PlayerController

var player_id : int
var player_name : String

var glory := GloryComponent.new()
var inventory := InventoryComponent.new()
var team := TeamComponent.new()
var wallet := WalletComponent.new()

signal player_lost


func _ready():
	RoundController.solo_detected.connect(_on_solo_detected)

	player_id = Globals.STEAM_ID
	player_name = Globals.STEAM_NAME

	if not glory.is_inside_tree():
		add_child(glory)

	if not team.is_inside_tree():
		add_child(team)

	if not wallet.is_inside_tree():
		add_child(wallet)

	_register_controller()
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
func _on_arena_lost():
	player_lost.emit()
	GameController.player_lost(self)


# =====================================
# MENU ACTIONS
# =====================================
func buy_item(item_id: String) -> bool:
	var item: Item = ItemDataBase.get_item(item_id)
	if item == null:
		return false
	if not wallet.has_enough(item.cost):
		return false
	wallet.remove_money(item.cost)
	inventory.add_item(item_id)
	return true

func lose_match():
	glory.subtract_glory(GameController.glory_loss)
	# Eliminated case is handled by the arena_lost signal above.
	# Non-eliminated: if alone go to start, otherwise wait for all_matches_done → city.
	if not glory.has_lost() and Globals.LOBBY_MEMBERS.size() <= 1:
		get_tree().change_scene_to_file(GameController.START_SCENE)

func win_match():
	glory.add_glory(GameController.glory_gain)
	
func get_champions_team_data() -> Array:
	return team.get_team_data()

func _on_solo_detected() -> void:
	print("Waiting 5 seconds to check if still alone...")
	await get_tree().create_timer(5.0).timeout
	
	# Check if still alone after 5 seconds
	var member_count = Steam.getNumLobbyMembers(Globals.LOBBY_ID)
	if member_count > 1:
		# Someone joined, continue normally
		print("Player joined, continuing...")
		return
	
	
	Steam.leaveLobby(Globals.LOBBY_ID)
	Globals.LOBBY_ID = 0
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	
	get_tree().change_scene_to_file("res://Scenes/gameScene/start meny/StartScene.tscn")
