class_name PopUp extends Control

signal go_to_shop


func _ready() -> void:
	hide()


func _on_go_to_shop_pressed() -> void:
	hide()
	go_to_shop.emit()


func _on_keep_fishing_pressed() -> void:
	hide()
