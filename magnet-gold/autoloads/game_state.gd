extends Node

signal update_cash(value: float)


var current_magnet: Magnets.Type = Magnets.Type.BASIC
var current_money_earned: float = 0.0:
	set(val):
		current_money_earned = val
		update_cash.emit(current_money_earned)


var inventory: Dictionary[ItemResource, int]


func update_items_to_dict(items: Array[Item]) -> void:
	for item in items:
		if item.item_resource in inventory.keys():
			inventory[item.item_resource] += 1
		else:
			inventory[item.item_resource] = 1
