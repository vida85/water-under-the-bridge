class_name Shop extends Control


@onready var main_container: VBoxContainer = %MainContainer

@onready var sell_button: Button = %SellButton
@onready var buy_button: Button = %BuyButton
@onready var leave_button: Button = %LeaveButton

const ITEM_HBOX = preload("res://scenes/popups/item_hbox.tscn")

var item_box_slot: ItemHBox

var item_resources: Dictionary = {}

func _ready() -> void:
	sell_button.pressed.connect(_on_sell_button)
	buy_button.pressed.connect(_on_buy_button)
	leave_button.pressed.connect(_on_leave_button)
	show_inventory.call_deferred()
	sell_button.grab_focus.call_deferred()


func show_inventory() -> void:
	for item_resource: ItemResource in GameState.inventory:
		if item_resources.has(item_resource):
			item_box_slot = item_resources[item_resource] as ItemHBox
		else:
			item_box_slot = ITEM_HBOX.instantiate()
			item_resources[item_resource] = item_box_slot

		if !item_box_slot.is_inside_tree():
			main_container.add_child(item_box_slot)

		item_box_slot.set_item(item_resource.texture, "", GameState.inventory[item_resource])
		item_box_slot.set_price(item_resource.value)


func _on_sell_button() -> void:
	pass


func _on_buy_button() -> void:
	pass


func _on_leave_button() -> void:
	hide()
