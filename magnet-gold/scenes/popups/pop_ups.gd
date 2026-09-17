class_name PopUp extends Control

signal go_to_shop
signal keep_fishing


@export var debug: bool

@onready var shop_button: Button = %ShopButton
@onready var keep_fishing_button: Button = %KeepFishingButton
@onready var item_container: VBoxContainer = %ItemContainer



func _ready() -> void:
	shop_button.pressed.connect(_on_go_to_shop_pressed)
	keep_fishing_button.pressed.connect(_on_keep_fishing_pressed)

	if debug:
		return
	hide()


func _on_go_to_shop_pressed() -> void:
	hide()
	go_to_shop.emit()


func _on_keep_fishing_pressed() -> void:
	hide()
	keep_fishing.emit()


func populate_scroll_container(items: Array) -> void:
	for item: Item in items:
		var item_box_slot:= HBoxContainer.new()
		var item_texture_rect:= TextureRect.new()
		var item_label:= Label.new()

		item_box_slot.custom_maximum_size = Vector2(-1.0, 15.0)
		item_box_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_box_slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		item_texture_rect.texture = item.item_resource.texture
		item_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		item_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		item_label.text = item.item_resource.name

		item_box_slot.add_child(item_texture_rect)
		item_box_slot.add_child(item_label)
		item_container.add_child(item_box_slot)
