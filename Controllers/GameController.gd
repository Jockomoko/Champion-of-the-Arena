
extends Node

signal game_over(winner: Node) # winner is first player to reach max glory, null if all lose

@export var players: Array[Node] = []

var _game_has_ended: bool = false

func _ready():
	for player in players:
		if not player.has_node("GloryComponent"):
			push_error("Player node missing GloryComponent: " + str(player.name))
			continue

		var glory = player.get_node("GloryComponent")
		glory.arena_won.connect(_on_player_arena_won, [player])
		glory.arena_lost.connect(_on_player_arena_lost, [player])

func _on_player_arena_won(player: Node) -> void:
	if _game_has_ended:
		return
	_game_has_ended = true
	print("Player ", player.name, " has won the arena! Game over.")
	emit_signal("game_over", player)

func _on_player_arena_lost(player: Node) -> void:
	if _game_has_ended:
		return

	# Check if all players lost
	for p in players:
		var glory = p.get_node("GloryComponent")
		if not glory.has_lost():
			return # someone still in arena

	_game_has_ended = true
	print("All players lost! Game over.")
	emit_signal("game_over", null)
