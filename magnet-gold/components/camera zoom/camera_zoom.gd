class_name CameraZoom extends Node


@export_subgroup("Setup")
@export var camera_node: Camera2D


var zoom_tween: Tween 


func handle_zoom(amount: Variant = 1.7, time: float = 1.5) -> void:
	if zoom_tween:
		zoom_tween.kill()

	if amount is float or amount is int:
		amount = Vector2(amount, amount)

	zoom_tween = get_tree().create_tween()
	zoom_tween.finished.connect(_zoom_finished)

	zoom_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	zoom_tween.tween_property(camera_node, "zoom", amount, time)


func _zoom_finished() -> void:
	pass
