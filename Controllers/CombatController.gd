extends Node

signal turn_started(champion: Champion)
signal turn_ended(champion: Champion)
signal combat_ended(winner: Champion)

var turn_order: Array[Champion] = []
var current_turn_index: int = 0
var champion_owners: Dictionary = {}

func start_combat(champions: Array[Champion]) -> void:
	champion_owners.clear()  # FIX 1: clear stale owner data from previous rounds
	turn_order = champions
	_sort_by_speed()
	current_turn_index = 0
	_broadcast_turn.rpc(0)

func register_owner(champion: Champion, steam_id: int) -> void:
	champion_owners[champion.champion_name] = steam_id  # FIX 3: use champion_name not node name

func _sort_by_speed() -> void:
	turn_order.sort_custom(func(a, b):
		return a.stats.base_stats["speed"] > b.stats.base_stats["speed"]
	)

func _start_turn() -> void:
	var champion = get_current_champion()
	var owner_id = champion_owners.get(champion.champion_name, -1)  # FIX 3
	print("Turn: %s (owner: %d)" % [champion.champion_name, owner_id])
	turn_started.emit(champion)

# FIX 4: removed sender_steam_id parameter — host derives it from peer identity
func request_use_ability(ability_id: String, target_name: String) -> void:
	if Globals.is_host:
		_server_use_ability(ability_id, target_name)
	else:
		_server_use_ability.rpc_id(1, ability_id, target_name)

# FIX 4: no longer accepts steam_id from client — looks it up securely
@rpc("any_peer", "reliable")
func _server_use_ability(ability_id: String, target_name: String) -> void:
	if not Globals.is_host:
		return

	# FIX 4: derive sender identity from peer, not from client-supplied value
	var sender_peer     = multiplayer.get_remote_sender_id()
	var sender_steam_id = Globals.peer_to_steam.get(sender_peer, Globals.STEAM_ID)

	var attacker = get_current_champion()

	# FIX 3: use champion_name for owner lookup
	if champion_owners.get(attacker.champion_name, -1) != sender_steam_id:
		push_error("Player %d tried to act out of turn!" % sender_steam_id)
		return

	var ability = AbilitiesDataBase.get_ability(ability_id)
	var target  = _find_champion_by_name(target_name)

	if not ability or not target:
		return

	var damage      = 0.0
	var mana_change = 0
	match ability.type:
		Ability.Type.MELEE, Ability.Type.SPELL:
			damage      = ability.get_damage(attacker.stats)
			mana_change = -ability.mana_cost
		Ability.Type.REST:
			mana_change = ability.mana_restore

	_apply_ability_result.rpc(attacker.champion_name, target_name, damage, mana_change)  # FIX 3

@rpc("authority", "call_local", "reliable")
func _apply_ability_result(attacker_name: String, target_name: String, damage: float, mana_change: int) -> void:
	var attacker = _find_champion_by_name(attacker_name)
	var target   = _find_champion_by_name(target_name)

	if attacker:
		attacker.health.current_mana += mana_change

	if target and damage > 0:
		target.health.take_damage(damage)

	turn_ended.emit(attacker)

	if Globals.is_host:
		_next_turn()

func _next_turn() -> void:
	# FIX 2: filter all dead champions out first, then advance index
	turn_order = turn_order.filter(func(c): return c.health.is_alive())
	if _check_combat_end():
		return
	current_turn_index = (current_turn_index + 1) % turn_order.size()
	_broadcast_turn.rpc(current_turn_index)

@rpc("authority", "call_local", "reliable")
func _broadcast_turn(turn_index: int) -> void:
	current_turn_index = turn_index
	_start_turn()

func _check_combat_end() -> bool:
	var alive = turn_order.filter(func(c): return c.health.is_alive())
	if alive.size() == 1:
		_broadcast_combat_end.rpc(alive[0].champion_name)
		return true
	return false

@rpc("authority", "call_local", "reliable")
func _broadcast_combat_end(winner_name: String) -> void:
	var winner = _find_champion_by_name(winner_name)
	combat_ended.emit(winner)

func get_current_champion() -> Champion:
	return turn_order[current_turn_index]

func is_my_turn() -> bool:
	var champion = get_current_champion()
	return champion_owners.get(champion.champion_name, -1) == Globals.STEAM_ID  # FIX 3

# FIX 3: use champion_name not node name for lookups
func _find_champion_by_name(champion_name: String) -> Champion:
	for champion in turn_order:
		if champion.champion_name == champion_name:
			return champion
	return null
