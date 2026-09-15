class_name Player extends CharacterBody2D

signal cast_line
signal cast_line_timeout


@export var magnet: Magnet
@export var platformer_input_component: PlatformerInputComponent = null
@export var platformer_movement_2d: PlatformerMovement2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var ap: AnimationPlayer = %AnimationPlayer

var _line_has_been_cast: bool = false
var _strength: float

const ORDER_INDEX_DEFAULT: int = 1
const ORDER_INDEX_LINECAST: int = 20

var throwing = false
var pulling = false
var fishing = false

func _ready() -> void:
	platformer_input_component.cast_magnet_request.connect(_on_cast_line_request)
	magnet.cast_line_timer.timeout.connect(_on_cast_line_timeout)


func _on_cast_line_request() -> void:
	print("Cast Line Requested")
	if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("cast_line")
	throw()


func _on_animation_finished() -> void:
	if not _line_has_been_cast:
		magnet.z_index = ORDER_INDEX_LINECAST
		_line_has_been_cast = true
		animated_sprite.animation_finished.disconnect(_on_animation_finished)
		magnet.cast(.5, global_position)
		cast_line.emit()


func _on_cast_line_timeout() -> void:
	magnet.z_index = ORDER_INDEX_DEFAULT
	_line_has_been_cast = false
	cast_line_timeout.emit()

func throw():
	throwing = true

func end_throw():
	throwing = false
	fishing = true

func end_pull():
	pulling = false

func pull():
	fishing = false
	pulling = true
