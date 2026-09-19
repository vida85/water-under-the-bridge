class_name PopUp extends Control

signal go_to_shop(shop_scene: Shop)
signal keep_fishing
signal can_cast(value: bool)

@export var debug: bool

@onready var shop_button: Button = %ShopButton
@onready var keep_fishing_button: Button = %KeepFishingButton
@onready var item_container: VBoxContainer = %ItemContainer

const SHOP = preload("uid://dhikhypod3wsd")
const ITEM_HBOX = preload("res://scenes/popups/item_hbox.tscn")

var item_resources: Dictionary = {}

var item_box_slot: ItemHBox


func _ready() -> void:
	shop_button.pressed.connect(_on_go_to_shop_pressed)
	keep_fishing_button.pressed.connect(_on_keep_fishing_pressed)
	keep_fishing_button.grab_focus()

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
			item_box_slot = item_resources[item.item_resource] as ItemHBox
		else:
			item_box_slot = ITEM_HBOX.instantiate()
			item_resources[item.item_resource] = item_box_slot

		if !item_box_slot.is_inside_tree():
			item_container.add_child(item_box_slot)

		item_box_slot.set_item(item.item_resource.texture, item.item_resource.name, GameState.inventory[item.item_resource])
