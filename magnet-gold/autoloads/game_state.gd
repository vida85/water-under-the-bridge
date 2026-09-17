extends Node


var current_magnet: Magnets.Type = Magnets.Type.BASIC
var current_money_earned: float = 0.0


var inventory: Array[ItemResource]


func update_items(items: Array[Item]) -> void:
	for item in items:
		inventory.append(item.item_resource)
