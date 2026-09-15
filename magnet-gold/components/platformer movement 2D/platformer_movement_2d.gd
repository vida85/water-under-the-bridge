class_name PlatformerMovement2D extends Node


@export_group("Components")
@export var body: CharacterBody2D
@export var input: PlatformerInputComponent

@export_group("Ground")
@export var max_speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2000.0

@export_group("Air")
@export var gravity: float = 1200.0
@export var jump_force: float = 400.0
@export var max_fall_speed: float = 700.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var short_jump_multiplier: float = 0.5

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0


func _physics_process(delta: float) -> void:
	apply_horizontal_movement(delta)
	apply_gravity(delta)
	update_grace_timers(delta)
	try_jump()
	try_cut_jump_short()

	body.move_and_slide()


func apply_horizontal_movement(delta: float) -> void:
	var move_direction: float = input.movement_direction
	body.determine_anim(move_direction)
	if move_direction == 0.0:
		body.velocity.x = move_toward(body.velocity.x, 0.0, friction * delta)
		return

	var target_speed := move_direction * max_speed
	body.velocity.x = move_toward(body.velocity.x, target_speed, acceleration * delta)


func apply_gravity(delta: float) -> void:
	if body.is_on_floor():
		return

	body.velocity.y = min(body.velocity.y + gravity * delta, max_fall_speed)


func update_grace_timers(delta: float) -> void:
	if body.is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)

	if input.is_jump_just_pressed:
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)


func try_jump() -> void:
	if _jump_buffer_timer == 0.0 or _coyote_timer == 0.0:
		return

	body.velocity.y = -jump_force
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0


func try_cut_jump_short() -> void:
	if !input.is_jump_just_released or body.velocity.y >= 0.0:
		return

	body.velocity.y *= short_jump_multiplier
