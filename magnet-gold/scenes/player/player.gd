class_name Player extends CharacterBody2D

signal cast_line
signal set_cast_bar


@export_group("Dependencies")
@export var magnet: Magnet
@export var cast_bar_ui: CastBar
@export var platformer_input_component: PlatformerInputComponent = null
@export var platformer_movement_2d: PlatformerMovement2D = null

@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _strength: float = .5
var is_line_cast: bool = false
var potential_items_attracted: Array[Item] = []

var aiming = false
var throwing = false
var pulling = false
var fishing = false



func _ready() -> void:
	set_cast_bar.connect(cast_bar_ui.pause_cast_bar)
	platformer_input_component.cast_magnet_request.connect(_on_cast_line_request)
	magnet.return_started.connect(pull)
	magnet.return_finished.connect(end_pull)
	magnet.splash_emitted.connect(cast_bar_ui.hide)


func aim():
	aiming = true
	animation_player.play("aim")


func throw():
	aiming = false
	throwing = true


func end_throw():
	animation_player.speed_scale = .5
	throwing = false
	fishing = true
	player_cast()


func end_pull():
	pulling = false
	animation_player.speed_scale = 1.0


func pull():
	fishing = false
	pulling = true


func determine_anim(move_direction: float) -> void:
	if move_direction < 0:
		animation_player.play("walk_left")
	elif move_direction > 0:
		animation_player.play("walk_right")
	elif aiming:
		animation_player.play("aim")
	elif throwing:
		animation_player.play("throw")
	elif pulling:
		animation_player.play("pull")
	elif fishing:
		animation_player.speed_scale = .5
		animation_player.play("pull")
	else:
		animation_player.play("idle")


func _on_cast_line_request() -> void:
	turn_off_player_mobility()

	if cast_bar_ui.is_processing() and cast_bar_ui.visible:
		set_cast_bar.emit()
		_strength = cast_bar_ui.get_cast_bar_set_position()
		throw()
		_set_cast_button(false)

	elif cast_bar_ui.visible == false:
		aim()
		cast_bar_ui.visible = true
		cast_bar_ui.resume_cast_bar()


func player_cast():
	is_line_cast = true
	magnet.cast(_strength, cast_bar_ui.BOTTOM, cast_bar_ui.TOP)
	cast_line.emit() # whomever needs to know (UI)


func on_cast_line_pull_up() -> void:
	is_line_cast = false
	magnet.triger_return_magnet_animation()


func on_item_area_entered(_area: Area2D) -> void:
	pass


func turn_off_player_mobility() -> void:
	platformer_input_component.turn_all_mobility_inputs_off()


func turn_on_player_mobility() -> void:
	platformer_input_component.turn_all_mobility_inputs_on()


func _set_cast_button(value: bool) -> void:
	platformer_input_component.set_cast_button(value)
