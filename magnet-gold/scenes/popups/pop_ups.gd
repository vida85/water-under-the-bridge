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
var item_button: Button


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
			item_button = item_resources[item.item_resource] as Button
		else:
			item_button = Button.new()
			item_resources[item.item_resource] = item_button

		# Button Layout
		item_button.custom_maximum_size = Vector2(-1.0, 25.0)
		item_button.size_flags_vertical = Control.SIZE_EXPAND
		item_button.clip_contents = true

		item_button.icon = item.item_resource.texture

		# Text Behavior
		item_button.text = item.item_resource.name
		item_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		item_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		item_button.autowrap_mode = TextServer.AUTOWRAP_WORD

		if not item_button.is_inside_tree():
			item_container.add_child(item_button)
