extends Node

signal turn_started(champion: Champion)
signal turn_ended(champion: Champion)
signal combat_ended(winner: Champion)

var turn_order: Array[Champion] = []
var current_turn_index: int = 0
var champion_owners: Dictionary = {}

func start_combat(champions: Array[Champion]) -> void:
	turn_order = champions
	sort_by_speed()
	current_turn_index = 0

func register_owner(champion: Champion, steam_id: int) -> void:
	champion_owners[champion.champion_name] = steam_id  # FIX 3: use champion_name not node name

func sort_by_speed() -> void:
	turn_order.sort_custom(func(a, b):
		if a.stats.base_stats["speed"] != b.stats.base_stats["speed"]:
			return a.stats.base_stats["speed"] > b.stats.base_stats["speed"]
		return a.champion_name < b.champion_name
	)

func _start_turn() -> void:
	var champion = get_current_champion()
	var owner_id = champion_owners.get(champion.champion_name, -1)
	print("Turn: %s (owner: %d)" % [champion.champion_name, owner_id])
	turn_started.emit(champion)

func request_use_ability(ability_id: String, target_name: String) -> void:
	if Globals.is_host:
		_server_use_ability(ability_id, target_name)
	else:
		_server_use_ability.rpc_id(1, ability_id, target_name)

@rpc("any_peer", "reliable")
func _server_use_ability(ability_id: String, target_name: String) -> void:
	if not Globals.is_host:
		return

	var attacker = get_current_champion()
	var ability = AbilitiesDataBase.get_ability(ability_id)
	var target  = _find_champion_by_name(target_name)

	if not ability:
		push_error("Ability '%s' does not exist" % ability_id)
		return

	if not target:
		push_error("'%s' is not a valid target" % target_name)
		return

	var damage = ability.get_damage(attacker.stats)
	var mana_change = ability.mana_restore - ability.mana_cost

	_apply_ability_result.rpc(attacker.champion_name, target.champion_name, damage, mana_change)

@rpc("authority", "call_local", "reliable")
func _apply_ability_result(attacker_name: String, target_name: String, damage: float, mana_change: int) -> void:
	var attacker = _find_champion_by_name(attacker_name)
	var target   = _find_champion_by_name(target_name)

	if attacker:
		attacker.current_mana += mana_change

	if target and damage > 0:
		target.health.take_damage(damage)

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
	turn_order = _get_alive_champions()
	if _check_combat_end():
		return
	current_turn_index = (current_turn_index + 1) % turn_order.size()
	_broadcast_turn.rpc(current_turn_index)

@rpc("authority", "call_local", "reliable")
func _broadcast_turn(turn_index: int) -> void:
	current_turn_index = turn_index
	_start_turn()

func _check_combat_end() -> bool:
	if turn_order.is_empty():
		return true
	var first_owner = champion_owners.get(turn_order[0].champion_name, -1)
	for champion in turn_order:
		if champion_owners.get(champion.champion_name, -1) != first_owner:
			return false
	_broadcast_combat_end.rpc(turn_order[0].champion_name)
	return true

@rpc("authority", "call_local", "reliable")
func _broadcast_combat_end(winner_name: String) -> void:
	var winner = _find_champion_by_name(winner_name)
	combat_ended.emit(winner)

func get_current_champion() -> Champion:
	return turn_order[current_turn_index]

func is_my_turn() -> bool:
	var champion = get_current_champion()
	return champion_owners.get(champion.champion_name, -1) == Globals.STEAM_ID  # FIX 3

func _find_champion_by_name(champion_name: String) -> Champion:
	for champion in turn_order:
		if champion.champion_name == champion_name:
			return champion
	return null

func broadcast_turn(turn_index: int) -> void:
	_broadcast_turn.rpc(turn_index)