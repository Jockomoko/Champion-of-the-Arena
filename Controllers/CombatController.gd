extends Node

signal turn_started(champion: Champion)
signal turn_ended(champion: Champion)
signal combat_ended(winner: Champion)

var turn_order: Array[Champion] = []
var all_champions: Array[Champion] = []  # permanent list, never shrinks
var current_turn_index: int = 0
var champion_owners: Dictionary = {}

func start_combat(champions: Array[Champion]) -> void:
	all_champions = champions.duplicate()
	turn_order = champions.duplicate()
	sort_by_speed()
	current_turn_index = 0

func register_owner(champion: Champion, steam_id: int) -> void:
	champion_owners[champion.combat_id] = steam_id

func sort_by_speed() -> void:
	turn_order.sort_custom(func(a, b):
		if not is_equal_approx(a.stats.base_stats["speed"], b.stats.base_stats["speed"]):
			return a.stats.base_stats["speed"] > b.stats.base_stats["speed"]
		return a.combat_id < b.combat_id
	)

func _start_turn() -> void:
	var champion = get_current_champion()
	if champion == null:
		return
	var owner_id = champion_owners.get(champion.combat_id, -1)
	print("Turn: %s (owner: %d)" % [champion.champion_name, owner_id])
	turn_started.emit(champion)

# Called by arena_scene on the host after ability.apply() finishes.
# Broadcasts turn_ended to all peers and advances the turn.
func request_turn_end(attacker_id: String) -> void:
	_broadcast_turn_ended.rpc(attacker_id)

@rpc("authority", "call_local", "reliable")
func _broadcast_turn_ended(attacker_id: String) -> void:
	var attacker = _find_champion(attacker_id)
	turn_ended.emit(attacker)
	if Globals.is_host:
		_next_turn()

func _get_alive_champions() -> Array[Champion]:
	var alive: Array[Champion] = []
	for champion in turn_order:
		if champion.health.is_alive():
			alive.append(champion)
	return alive

func _next_turn() -> void:
	var current_champion = get_current_champion()  # save before refresh
	turn_order = _get_alive_champions()
	if _check_combat_end():
		return
	# Find the attacker's new position in the refreshed array before advancing
	var new_index = turn_order.find(current_champion)
	if new_index == -1:
		new_index = current_turn_index - 1  # attacker died; back up so +1 is correct
	current_turn_index = (new_index + 1) % turn_order.size()
	_broadcast_turn.rpc(turn_order[current_turn_index].combat_id)

@rpc("authority", "call_local", "reliable")
func _broadcast_turn(next_combat_id: String) -> void:
	turn_order = _get_alive_champions()
	if turn_order.is_empty():
		return
	var champion = _find_champion(next_combat_id)
	if not champion:
		return
	current_turn_index = turn_order.find(champion)
	if current_turn_index == -1:
		current_turn_index = 0
	_start_turn()

func _check_combat_end() -> bool:
	if turn_order.is_empty():
		return true
	var first_owner = champion_owners.get(turn_order[0].combat_id, -1)
	for champion in turn_order:
		if champion_owners.get(champion.combat_id, -1) != first_owner:
			return false
	_broadcast_combat_end.rpc(turn_order[0].combat_id)
	return true

@rpc("authority", "call_local", "reliable")
func _broadcast_combat_end(winner_id: String) -> void:
	var winner = _find_champion(winner_id)
	combat_ended.emit(winner)

func get_current_champion() -> Champion:
	if turn_order.is_empty() or current_turn_index >= turn_order.size():
		return null
	return turn_order[current_turn_index]

func is_my_turn() -> bool:
	var champion = get_current_champion()
	if champion == null:
		return false
	return champion_owners.get(champion.combat_id, -1) == Globals.STEAM_ID

func _find_champion(id: String) -> Champion:
	for champion in all_champions:
		if champion.combat_id == id:
			return champion
	return null

func broadcast_first_turn() -> void:
	if turn_order.is_empty():
		return
	_broadcast_turn.rpc(turn_order[0].combat_id)
