class_name Shop extends Control


@onready var main_container: VBoxContainer = %MainContainer

@onready var leave_button: Button = %LeaveButton

@onready var tab_container: TabContainer = %TabContainer

@onready var magnet_1_button: Button = %Magnet_1_Button
@onready var magnet_2_button: Button = %Magnet_2_Button

const ITEM_HBOX = preload("res://scenes/popups/item_hbox.tscn")
const MAGNET_RESOURCE = preload("uid://crh5dh2gulls8")

var item_box_slot: ItemHBox

var item_resources: Dictionary = {}


func _ready() -> void:
	leave_button.pressed.connect(_on_leave_button)
	magnet_1_button.pressed.connect(_on_magnet_1_pressed)
	magnet_2_button.pressed.connect(_on_magnet_2_pressed)
	show_inventory.call_deferred()
	tab_container.grab_focus.call_deferred()


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


func _on_leave_button() -> void:
	hide()


func _on_magnet_1_pressed() -> void:
	# Don't forget to update the GameState.current_magnet resource | MAGNET_RESOURCE
	# magnet influence is the radius of the area2D
	print("Purchased Magnet 1")
	pass


func _on_magnet_2_pressed() -> void:
	# Don't forget to update the GameState.current_magnet resource | MAGNET_RESOURCE
	# magnet influence is the radius of the area2D
	print("Purchased Magnet 2")
	pass
