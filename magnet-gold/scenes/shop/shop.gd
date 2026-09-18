class_name Shop extends Control


@onready var main_container: VBoxContainer = %MainContainer

@onready var sell_button: Button = %SellButton
@onready var buy_button: Button = %BuyButton
@onready var leave_button: Button = %LeaveButton

@onready var sell_tab: ScrollContainer = %SellTab
@onready var buy_tab: ScrollContainer = %BuyTab

@onready var tab_container: TabContainer = %TabContainer

var item_box_slot: HBoxContainer
var item_texture_rect: TextureRect
var item_button: Button

var item_resources: Dictionary = {}


func _ready() -> void:
	tab_container.tab_clicked.connect(_on_tab_button_pressed)

	sell_button.pressed.connect(_on_sell_button)
	buy_button.pressed.connect(_on_buy_button)
	leave_button.pressed.connect(_on_leave_button)

	sell_button.visible = true
	buy_button.visible = false

	show_inventory.call_deferred()


func show_inventory() -> void:
	for item_resource: ItemResource in GameState.inventory:
		if item_resources.has(item_resource):
			item_box_slot     = item_resources[item_resource][0] as HBoxContainer
			item_texture_rect = item_resources[item_resource][1] as TextureRect
			item_button       = item_resources[item_resource][2] as Button
		else:
			item_box_slot     = HBoxContainer.new()
			item_texture_rect = TextureRect.new()
			item_button       = Button.new()
			item_resources[item_resource] = [item_box_slot, item_texture_rect, item_button]

		#item_box_slot.custom_maximum_size = Vector2(-1.0, 12.0)
	
		#item_texture_rect.custom_maximum_size = Vector2(10, 10)
		item_texture_rect.texture = item_resource.texture
		item_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		item_button.text = str(GameState.inventory[item_resource]) + " X $" + str(item_resource.value)

		if !item_box_slot.is_inside_tree():
			item_box_slot.add_child(item_texture_rect)
			item_box_slot.add_child(item_button)
			main_container.add_child(item_box_slot)


func _on_sell_button() -> void:
	pass


func _on_buy_button() -> void:
	pass


func _on_leave_button() -> void:
	hide()


func _on_tab_button_pressed(tab_idx: int) -> void:
	match tab_idx:
		1:
			sell_button.visible = false
			buy_button.visible = true
		0:
			sell_button.visible = true
			buy_button.visible = false
