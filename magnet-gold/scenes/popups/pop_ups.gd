class_name PopUp extends Control

signal go_to_shop
signal keep_fishing
signal can_cast(value: bool)


@onready var shop_button: Button = %ShopButton
@onready var keep_fishing_button: Button = %KeepFishingButton
@onready var win_game: Button = %WinGame

@onready var win_game_sfx: AudioStreamPlayer = $WinGameSFX


@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var item_container: VBoxContainer = %ItemContainer
@onready var description_label: Label = %DescriptionLabel

const SCROLLBAR_WIDTH: float = 2.0
const OUTRO = preload("res://scenes/outro/Outro.tscn")


const ITEM_BUTTON = preload("res://scenes/popups/item_button.tscn")

var item_resources: Dictionary = {}
var item_button_slot: ItemButton


func _ready() -> void:
	win_game.hide()

	win_game.pressed.connect(_on_win_game_pressed)
	shop_button.pressed.connect(_on_go_to_shop_pressed)
	keep_fishing_button.pressed.connect(_on_keep_fishing_pressed)
	visibility_changed.connect(_on_visibility_changed)

	scroll_container.get_v_scroll_bar().custom_minimum_size.x = SCROLLBAR_WIDTH
	_focus_first_selectable()

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
	for item: Item in items:
		if "heirloom" in item.item_resource.name.to_lower():
			win_game_sfx.play()
			win_game.show()
			shop_button.hide()
			keep_fishing_button.hide()

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

	_wire_last_item_focus()
	_focus_first_selectable()


func _wire_last_item_focus() -> void:
	var items: Array[Node] = item_container.get_children()
	for item_button: ItemButton in items:
		item_button.button.focus_neighbor_bottom = NodePath()

	if not items.is_empty():
		var last_item: ItemButton = items[-1]
		last_item.button.focus_neighbor_bottom = last_item.button.get_path_to(_get_next_focus_target())


func _get_next_focus_target() -> Button:
	return win_game if win_game.visible else shop_button


func _focus_first_selectable() -> void:
	if item_container.get_child_count() > 0:
		(item_container.get_child(0) as ItemButton).focus_item()
	else:
		_get_next_focus_target().grab_focus()


func _on_item_hovered(description: String) -> void:
	description_label.text = description


func _on_item_unhovered() -> void:
	description_label.text = "..."


func _clear_items() -> void:
	for child in item_container.get_children():
		# remove_child immediately, since queue_free() alone leaves the node
		# as a child until end of frame — get_child(0) right after this call
		# would otherwise still return the old, about-to-be-freed button.
		item_container.remove_child(child)
		child.queue_free()
	item_resources.clear()


func _on_win_game_pressed() -> void:
	get_tree().change_scene_to_packed.call_deferred(OUTRO)
