class_name ItemHBox extends HBoxContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var name_label: Label = %NameLabel
@onready var quantity_label: Label = %QuantityLabel
@onready var price_label: Label = %PriceLabel


func set_item(texture: Texture2D, name: String, qty: int) -> void:
	texture_rect.texture = texture
	name_label.text = name
	quantity_label.text = "x" + str(qty)


func set_price(price: float) -> void:
	price_label.text = "$" + str(price)
	price_label.show()
