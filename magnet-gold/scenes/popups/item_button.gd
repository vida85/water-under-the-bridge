class_name ItemButton extends Button

signal item_hovered(description: String)
signal item_unhovered

@onready var texture_rect: TextureRect = %TextureRect
@onready var name_label: Label = %NameLabel
@onready var quantity_label: Label = %QuantityLabel
@onready var price_label: Label = %PriceLabel

var description: String = ""


func _ready() -> void:
	mouse_entered.connect(_on_hover_started)
	focus_entered.connect(_on_hover_started)
	mouse_exited.connect(_on_mouse_exited)
	focus_exited.connect(_on_focus_exited)


func set_item(texture: Texture2D, _name: String, qty: int) -> void:
	texture_rect.texture = texture
	name_label.text = _name
	quantity_label.text = "x" + str(qty)


func set_price(price: float, prefix: String = "") -> void:
	price_label.text = prefix + "$" + str(price)
	price_label.show()


func set_description(_text: String) -> void:
	description = _text


func _on_hover_started() -> void:
	item_hovered.emit(description)


func _on_mouse_exited() -> void:
	if not has_focus():
		item_unhovered.emit()


func _on_focus_exited() -> void:
	if not is_hovered():
		item_unhovered.emit()
