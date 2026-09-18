class_name PopUp extends Control

signal go_to_shop(shop_scene: Shop)
signal keep_fishing
signal can_cast(value: bool)

@export var debug: bool

@onready var shop_button: Button = %ShopButton
@onready var keep_fishing_button: Button = %KeepFishingButton
@onready var item_container: VBoxContainer = %ItemContainer

const SHOP = preload("uid://dhikhypod3wsd")

var item_resources: Dictionary = {}

var item_box_slot: HBoxContainer
var item_texture_rect: TextureRect
var item_label: Label


func _ready() -> void:
	shop_button.pressed.connect(_on_go_to_shop_pressed)
	keep_fishing_button.pressed.connect(_on_keep_fishing_pressed)

	if debug:
		return
	hide()


func _on_go_to_shop_pressed() -> void:
	hide()
	go_to_shop.emit(SHOP)


func _on_keep_fishing_pressed() -> void:
	hide()
	keep_fishing.emit()
	can_cast.emit(true)


func populate_scroll_container(items: Array) -> void:
	if items.is_empty():
		_on_keep_fishing_pressed()
		return

	GameState.update_items_to_dict(items)
	"""
	I have items coming in as an Array[Item]
	[Item] has a item_resource property
	I pass items Array[Item] to a Dictionary with keys as [Item.IteamResource, int]
	GameState.update_items_to_dict(items) keeping track of individual items count
	"""
	for item: Item in items:
		if item_resources.has(item.item_resource):
			item_box_slot     = item_resources[item.item_resource][0] as HBoxContainer
			item_texture_rect = item_resources[item.item_resource][1] as TextureRect
			item_label        = item_resources[item.item_resource][2] as Label
		else:
			item_box_slot     = HBoxContainer.new()
			item_texture_rect = TextureRect.new()
			item_label        = Label.new()
			item_resources[item.item_resource] = [item_box_slot, item_texture_rect, item_label]

		item_box_slot.custom_maximum_size = Vector2(-1.0, 15.0)
		item_box_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_box_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		item_texture_rect.texture = item.item_resource.texture
		item_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		item_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		item_label.text = item.item_resource.name + " -- " + str(GameState.inventory[item.item_resource])

		if !item_box_slot.is_inside_tree():
			item_box_slot.add_child(item_texture_rect)
			item_box_slot.add_child(item_label)
			item_container.add_child(item_box_slot)
