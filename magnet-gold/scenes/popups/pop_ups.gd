class_name PopUp extends Control

signal go_to_shop
signal keep_fishing


@export var debug: bool

@onready var shop_button: Button = %ShopButton
@onready var keep_fishing_button: Button = %KeepFishingButton



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
