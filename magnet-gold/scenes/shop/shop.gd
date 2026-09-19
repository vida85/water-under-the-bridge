class_name Shop extends Control


@onready var main_container: VBoxContainer = %MainContainer
@onready var main_buy_container: VBoxContainer = %MainBuyContainer

@onready var leave_button: Button = %LeaveButton
@onready var description_label: Label = %DescriptionLabel

@onready var tab_bar: TabBar = %TabBar
@onready var sell_tab: ScrollContainer = %SellTab
@onready var buy_tab: ScrollContainer = %BuyTab

const ITEM_BUTTON = preload("res://scenes/popups/item_button.tscn")
const MAGNET_RESOURCE: MagnetResource = preload("uid://crh5dh2gulls8")

var item_button_slot: ItemButton

var item_resources: Dictionary = {}


func _ready() -> void:
	leave_button.pressed.connect(_on_leave_button)
	tab_bar.tab_changed.connect(_on_tab_changed)
	show_inventory.call_deferred()
	show_magnets.call_deferred()
	tab_bar.grab_focus.call_deferred()


func _on_tab_changed(tab_idx: int) -> void:
	sell_tab.visible = tab_idx == 0
	buy_tab.visible = tab_idx == 1


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
	#GameState.current_money_earned += item_resource.value
	GameState.update_cash(item_resource.value)
	item_resources.erase(item_resource)
	button.queue_free()


func _on_buy_magnet_pressed(magnet_type: Magnets.Type, button: ItemButton) -> void:
	var price: float = MAGNET_RESOURCE.magnet_prices[magnet_type]
	if GameState.current_money_earned < price:
		description_label.text = "Not enough cash..."
		return

	GameState.update_cash(-price)
	GameState.current_magnet = magnet_type
	button.queue_free()


func _on_leave_button() -> void:
	hide()


func _on_item_hovered(description: String) -> void:
	description_label.text = description


func _on_item_unhovered() -> void:
	description_label.text = ""
