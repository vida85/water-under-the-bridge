class_name Shop extends Control


@onready var main_container: VBoxContainer = %MainContainer

@onready var sell_button: Button = %SellButton
@onready var buy_button: Button = %BuyButton
@onready var leave_button: Button = %LeaveButton


var item_box_slot: HBoxContainer
var item_texture_rect: TextureRect
var item_label: Label

var item_resources: Dictionary = {}

func _ready() -> void:
	sell_button.pressed.connect(_on_sell_button)
	buy_button.pressed.connect(_on_buy_button)
	leave_button.pressed.connect(_on_leave_button)
	show_inventory.call_deferred()


func show_inventory() -> void:
	for item_resource: ItemResource in GameState.inventory:
		if item_resources.has(item_resource):
			item_box_slot     = item_resources[item_resource][0] as HBoxContainer
			item_texture_rect = item_resources[item_resource][1] as TextureRect
			item_label        = item_resources[item_resource][2] as Label
		else:
			item_box_slot     = HBoxContainer.new()
			item_texture_rect = TextureRect.new()
			item_label        = Label.new()
			item_resources[item_resource] = [item_box_slot, item_texture_rect, item_label]

		item_box_slot.custom_maximum_size = Vector2(-1.0, 12.0)
	
		item_texture_rect.custom_maximum_size = Vector2(10, 10)
		item_texture_rect.texture = item_resource.texture
		item_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		item_label.text = str(GameState.inventory[item_resource])

		if !item_box_slot.is_inside_tree():
			item_box_slot.add_child(item_texture_rect)
			item_box_slot.add_child(item_label)
			main_container.add_child(item_box_slot)


func _on_sell_button() -> void:
	pass


func _on_buy_button() -> void:
	pass


func _on_leave_button() -> void:
	hide()
