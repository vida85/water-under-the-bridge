class_name CameraShake extends Node

signal shake_finished()

@export_group("Setup")
@export var camera_node: Node2D

@export_group("Shake")
## Peak offset in pixels at full trauma.
@export var max_offset := Vector2(24.0, 16.0)
## Peak roll in radians at full trauma.
@export var max_roll: float = 0.08
## Seconds for full trauma to drain to zero.
@export var duration: float = 1.0
## 2 makes small hits subtle and big ones punch. 1 is linear.
@export_range(1, 4) var trauma_power: int = 2
## How fast the shake oscillates.
@export var shake_speed: float = 28.0


var _trauma: float = 0.0
var _time: float = 0.0
var _offset_default: Vector2
var _rotation_default: float
var _noise := FastNoiseLite.new()



func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 0.5
	set_process(false)
	if camera_node == null:
		camera_node = get_parent() as Camera2D
		if camera_node == null:
			printerr("Assign a Camera2D to camera_node.")
			return

	if camera_node is Camera2D:
		_offset_default = camera_node.offset
		_rotation_default = camera_node.rotation
	else:
		_offset_default = camera_node.position
		_rotation_default = camera_node.rotation

## Adds to any shake already running. 0.4 for a footstep, 1.0 for an explosion.
func add_trauma(amount: float = 4.0) -> void:
	if camera_node == null or amount <= 0.0:
		return

	_trauma = minf(_trauma + amount, 1.0)
	set_process(true)


## Cancel immediately and restore the camera.
func stop() -> void:
	_trauma = 0.0
	if camera_node != null:
		camera_node.offset = _offset_default
		camera_node.rotation = _rotation_default
	set_process(false)


func _process(delta: float) -> void:
	if duration > 0.0:
		_trauma = maxf(_trauma - delta / duration, 0.0)
	_time += delta * shake_speed

	var shake: float = pow(_trauma, trauma_power)

	if camera_node is Camera2D:
		# Using fancy noise texture coordinates for greater random action within a given noise axis.
		camera_node.offset.x = _offset_default.x + (max_offset.x * shake * _noise.get_noise_2d(_time, 0.0))
		camera_node.offset.y = _offset_default.y + (max_offset.y * shake * _noise.get_noise_2d(_time, 100.0))
		camera_node.rotation = _rotation_default + (max_roll * shake * _noise.get_noise_2d(_time, 200.0))
	else:
		camera_node.position.x = _offset_default.x + (max_offset.x * shake * _noise.get_noise_2d(_time, 0.0))
		camera_node.position.y = _offset_default.y + (max_offset.y * shake * _noise.get_noise_2d(_time, 100.0))
		camera_node.rotation = _rotation_default + (max_roll * shake * _noise.get_noise_2d(_time, 200.0))

	if is_zero_approx(_trauma):
		if camera_node is Camera2D:
			camera_node.offset = _offset_default
		else:
			camera_node.position = _offset_default
		camera_node.rotation = _rotation_default
		set_process(false)
		shake_finished.emit()
