class_name Shop extends Control


@onready var main_container: VBoxContainer = %MainContainer

@onready var leave_button: Button = %LeaveButton

@onready var sell_tab: ScrollContainer = %SellTab
@onready var buy_tab: ScrollContainer = %BuyTab

@onready var tab_container: TabContainer = %TabContainer

var item_box_container: MarginContainer
var item_button: Button

var item_resources: Dictionary = {}


func _ready() -> void:
	leave_button.pressed.connect(_on_leave_button)

	show_inventory.call_deferred()


func show_inventory() -> void:
	for item_resource: ItemResource in GameState.inventory:
		if item_resources.has(item_resource):
			item_box_container = item_resources[item_resource][0] as MarginContainer
			item_button = item_resources[item_resource][2] as Button
		else:
			item_box_container = MarginContainer.new()
			item_button = Button.new()
			item_resources[item_resource] = [item_box_container, item_button]

		item_box_container.add_theme_constant_override("margin_top", 1)
		item_box_container.add_theme_constant_override("margin_bottom", 1)
		item_box_container.add_theme_constant_override("margin_left", 2)

		item_button.custom_maximum_size = Vector2(95.0, 30.0)
		item_button.icon = item_resource.texture
		item_button.text = str(GameState.inventory[item_resource]) + " X $" + str(item_resource.value)

		if !item_box_container.is_inside_tree():
			item_box_container.add_child(item_button)
			main_container.add_child(item_box_container)


func _on_leave_button() -> void:
	hide()
