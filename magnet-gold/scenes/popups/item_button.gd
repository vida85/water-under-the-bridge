class_name ItemButton extends HBoxContainer

signal pressed
signal item_hovered(description: String)
signal item_unhovered

@onready var button: Button = %Button
@onready var focus_indicator: TextureRect = %FocusIndicator
@onready var texture_rect: TextureRect = %TextureRect
@onready var name_label: Label = %NameLabel
@onready var quantity_label: Label = %QuantityLabel
@onready var price_label: Label = %PriceLabel

var description: String = ""


func _ready() -> void:
	button.pressed.connect(func() -> void: pressed.emit())
	button.mouse_entered.connect(_on_hover_started)
	button.focus_entered.connect(_on_hover_started)
	button.mouse_exited.connect(_on_mouse_exited)
	button.focus_exited.connect(_on_focus_exited)


func focus_item() -> void:
	button.grab_focus()


func set_item(texture: Texture2D, name: String, qty: int) -> void:
	texture_rect.texture = texture
	name_label.text = name
	quantity_label.text = "x" + str(qty)


func set_price(price: float, prefix: String = "") -> void:
	price_label.text = prefix + "$" + str(price)
	price_label.show()


func set_description(text: String) -> void:
	description = text


func _on_hover_started() -> void:
	focus_indicator.show()
	item_hovered.emit(description)


func _on_mouse_exited() -> void:
	if not button.has_focus():
		focus_indicator.hide()
		item_unhovered.emit()


func _on_focus_exited() -> void:
	if not button.is_hovered():
		focus_indicator.hide()
		item_unhovered.emit()
