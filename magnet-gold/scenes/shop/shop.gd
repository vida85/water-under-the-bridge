class_name Shop extends Control


@onready var main_container: VBoxContainer = %MainContainer
@onready var main_buy_container: VBoxContainer = %MainBuyContainer

@onready var leave_button: Button = %LeaveButton
@onready var description_label: Label = %DescriptionLabel

@onready var tab_bar: TabBar = %TabBar
@onready var sell_tab: ScrollContainer = %SellTab
@onready var buy_tab: ScrollContainer = %BuyTab
@onready var arrow_left: TextureRect = %ArrowLeft
@onready var arrow_right: TextureRect = %ArrowRight
@onready var coin_sfx: AudioStreamPlayer = %CoinSFX

const ITEM_BUTTON = preload("res://scenes/popups/item_button.tscn")
const MAGNET_RESOURCE: MagnetResource = preload("uid://crh5dh2gulls8")
const ARROW_TEXTURE = preload("uid://bvuekuopv8dq7")
const ARROW_ACTIVE_TEXTURE = preload("uid://cr8ra0ywula1k")

var item_button_slot: ItemButton

var item_resources: Dictionary = {}


func _ready() -> void:
	leave_button.pressed.connect(_on_leave_button)
	tab_bar.tab_changed.connect(_on_tab_changed)
	show_inventory.call_deferred()
	show_magnets.call_deferred()
	_focus_first_in_active_tab.call_deferred()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_left"):
		tab_bar.current_tab = 0
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		tab_bar.current_tab = 1
		get_viewport().set_input_as_handled()


func _on_tab_changed(tab_idx: int) -> void:
	sell_tab.visible = tab_idx == 0
	buy_tab.visible = tab_idx == 1

	arrow_left.texture = ARROW_ACTIVE_TEXTURE if tab_idx == 0 else ARROW_TEXTURE
	arrow_right.texture = ARROW_ACTIVE_TEXTURE if tab_idx == 1 else ARROW_TEXTURE

	_focus_first_in_active_tab()


func _focus_first_in_active_tab() -> void:
	var active_container: VBoxContainer = main_container if tab_bar.current_tab == 0 else main_buy_container
	if active_container.get_child_count() > 0:
		active_container.get_child(0).grab_focus()
	else:
		leave_button.grab_focus()


func show_inventory() -> void:
	for item_resource: ItemResource in GameState.inventory:
		if item_resources.has(item_resource):
			item_button_slot = item_resources[item_resource] as ItemButton
		else:
			item_button_slot = ITEM_BUTTON.instantiate()
			item_resources[item_resource] = item_button_slot
			item_button_slot.pressed.connect(_on_sell_item_pressed.bind(item_resource, item_button_slot))
			item_button_slot.item_hovered.connect(_on_item_hovered)
			item_button_slot.item_unhovered.connect(_on_item_unhovered)

		if !item_button_slot.is_inside_tree():
			main_container.add_child(item_button_slot)

		item_button_slot.set_item(item_resource.icon, item_resource.name, GameState.inventory[item_resource])
		item_button_slot.set_price(item_resource.value, "+")
		item_button_slot.set_description(item_resource.item_description)


func show_magnets() -> void:
	for magnet_type: Magnets.Type in MAGNET_RESOURCE.magnet_prices:
		if magnet_type == GameState.current_magnet:
			continue

		var magnet_button: ItemButton = ITEM_BUTTON.instantiate()
		main_buy_container.add_child(magnet_button)
		magnet_button.set_item(MAGNET_RESOURCE.magnet_icons[magnet_type], MAGNET_RESOURCE.magnet_names[magnet_type], 0)
		magnet_button.set_price(MAGNET_RESOURCE.magnet_prices[magnet_type], "-")
		magnet_button.set_description(MAGNET_RESOURCE.magnet_descriptions[magnet_type])
		magnet_button.pressed.connect(_on_buy_magnet_pressed.bind(magnet_type, magnet_button))
		magnet_button.item_hovered.connect(_on_item_hovered)
		magnet_button.item_unhovered.connect(_on_item_unhovered)


func _on_sell_item_pressed(item_resource: ItemResource, button: ItemButton) -> void:
	GameState.inventory.erase(item_resource)
	GameState.update_cash(item_resource.value)
	item_resources.erase(item_resource)
	coin_sfx.play()
	_remove_and_refocus(button, main_container)


func _on_buy_magnet_pressed(magnet_type: Magnets.Type, button: ItemButton) -> void:
	var price: float = MAGNET_RESOURCE.magnet_prices[magnet_type]
	if GameState.current_money_earned < price:
		description_label.text = "Not enough cash..."
		return

	GameState.update_cash(-price)
	GameState.current_magnet = magnet_type
	coin_sfx.play()
	_remove_and_refocus(button, main_buy_container)


func _remove_and_refocus(button: ItemButton, container: VBoxContainer) -> void:
	var index: int = button.get_index()
	container.remove_child(button)
	button.queue_free()

	if container.get_child_count() > 0:
		var next_index: int = clampi(index, 0, container.get_child_count() - 1)
		container.get_child(next_index).grab_focus()
	else:
		leave_button.grab_focus()


func _on_leave_button() -> void:
	hide()


func _on_item_hovered(description: String) -> void:
	description_label.text = description


func _on_item_unhovered() -> void:
	description_label.text = "..."
