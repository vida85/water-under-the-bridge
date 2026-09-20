class_name PopUp extends Control

signal go_to_shop
signal keep_fishing
signal can_cast(value: bool)

@export var debug: bool

@onready var shop_button: Button = %ShopButton
@onready var keep_fishing_button: Button = %KeepFishingButton
@onready var item_container: VBoxContainer = %ItemContainer
@onready var description_label: Label = %DescriptionLabel


const ITEM_BUTTON = preload("res://scenes/popups/item_button.tscn")

var item_resources: Dictionary = {}
var item_button_slot: ItemButton


func _ready() -> void:
	shop_button.pressed.connect(_on_go_to_shop_pressed)
	keep_fishing_button.pressed.connect(_on_keep_fishing_pressed)
	visibility_changed.connect(_on_visibility_changed)
	_focus_first_selectable()

	if debug:
		return
	hide()


func _on_visibility_changed() -> void:
	if visible:
		_focus_first_selectable()


func _on_go_to_shop_pressed() -> void:
	hide()
	go_to_shop.emit()


func _on_keep_fishing_pressed() -> void:
	hide()
	keep_fishing.emit()
	can_cast.emit(true)


func populate_scroll_container(items: Array) -> void:
	if items.is_empty():
		_on_keep_fishing_pressed()
		return

	_clear_items()
	GameState.update_items_to_dict(items)
	"""
	I have items coming in as an Array[Item]
	[Item] has a item_resource property
	I pass items Array[Item] to a Dictionary with keys as [Item.IteamResource, int]
	GameState.update_items_to_dict(items) keeping track of individual items count
	"""
	for item: Item in items:
		if item_resources.has(item.item_resource):
			item_button_slot = item_resources[item.item_resource] as ItemButton
		else:
			item_button_slot = ITEM_BUTTON.instantiate()
			item_resources[item.item_resource] = item_button_slot
			item_button_slot.item_hovered.connect(_on_item_hovered)
			item_button_slot.item_unhovered.connect(_on_item_unhovered)

		if !item_button_slot.is_inside_tree():
			item_container.add_child(item_button_slot)

		item_button_slot.set_item(item.item_resource.icon, item.item_resource.name, GameState.inventory[item.item_resource])
		item_button_slot.set_description(item.item_resource.item_description)

	_focus_first_selectable()


func _focus_first_selectable() -> void:
	if item_container.get_child_count() > 0:
		(item_container.get_child(0) as ItemButton).focus_item()
	else:
		shop_button.grab_focus()


func _on_item_hovered(description: String) -> void:
	description_label.text = description


func _on_item_unhovered() -> void:
	description_label.text = "..."


func _clear_items() -> void:
	for child in item_container.get_children():
		child.queue_free()
	item_resources.clear()
