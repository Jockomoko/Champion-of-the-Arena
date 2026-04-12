extends Node
class_name WalletComponent

var money: int = 0

signal money_changed(new_amount: int)


func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)


func remove_money(amount: int) -> void:
	money = max(0, money - amount)
	money_changed.emit(money)


func reset_money(starting_amount: int = 0) -> void:
	money = starting_amount
	money_changed.emit(money)


func has_enough(amount: int) -> bool:
	return money >= amount
