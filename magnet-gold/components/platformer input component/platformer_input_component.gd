class_name PlatformerInputComponent extends Node


signal cast_magnet_request
signal open_shop_request
signal cast_availability_changed(value: bool)


var movement_direction: float = 0.0
var is_jump_just_pressed: bool
var is_jump_just_released: bool

var strength_amount: float = 0.0
var max_strength_amount: float = 5.0

var _can_cast_magnet: bool = true

func _physics_process(_delta: float) -> void:
	gather_input()


func gather_input() -> void:
	## Godot inputs needs to be set in Project Inputs 'move_left', 'move_right', 'jump'
	movement_direction = Input.get_axis("left", "right")
	is_jump_just_pressed = Input.is_action_just_pressed("jump")
	is_jump_just_released = Input.is_action_just_released("jump")


func _unhandled_input(event: InputEvent) -> void:
	if _can_cast_magnet and event.is_action_pressed("cast_line"):
		cast_magnet_request.emit()

	if _can_cast_magnet and event.is_action_pressed("pull_up_quickly"):
		open_shop_request.emit()


func turn_all_mobility_inputs_off() -> void:
	set_physics_process(false)
	movement_direction = 0.0
	is_jump_just_pressed = false
	is_jump_just_released = false


func turn_all_mobility_inputs_on() -> void:
	set_physics_process(true)


func set_cast_button(value: bool) -> void:
	_can_cast_magnet = value
	cast_availability_changed.emit(value)
