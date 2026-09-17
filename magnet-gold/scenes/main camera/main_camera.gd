class_name MainCamera extends Camera2D


@export var camera_shake: CameraShake
@export var camera_zoom: CameraZoom


func add_shake() -> void:
	camera_shake.add_trauma(.25)
