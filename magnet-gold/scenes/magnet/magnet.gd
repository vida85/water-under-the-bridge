class_name Magnet extends Node2D

signal return_started
signal return_finished

@export_group("Rope")
@export var rope_color: Color
@export var rope_outline_color: Color
@export var rope_highlight_color: Color
@export var hand_position: Marker2D


@onready var cast_line_timer: Timer = %CastLineTimer
@onready var line: Line2D = $Line2D
@onready var magnet_area: Area2D = %MagnetArea
@onready var magnet_sprite: Sprite2D = %MagnetSprite
@onready var splash: GPUParticles2D = %Splash


const MAX_LINE_LENGTH: float = 5.0
const MIN_LINE_LENGTH: float = 3.6

const ORDER_INDEX_DEFAULT: int = 1
const ORDER_INDEX_LINECAST: int = 20

var cast_strength: float

var pos: Vector2
var prev_pos: Vector2
var _gravity: Vector2 = Vector2(0, 600)

var cast_line: bool = false
var is_returning: bool = false
var default_position: Vector2



func _ready() -> void:
	cast_line_timer.timeout.connect(_on_cast_timer_timeout)
	magnet_area.area_entered.connect(_on_area_enter)
	z_index = ORDER_INDEX_DEFAULT

	pos = hand_position.position
	prev_pos = hand_position.position
	magnet_area.position = hand_position.position


func _physics_process(delta: float) -> void:
	if cast_line:
		var velocity: Vector2 = pos - prev_pos
		if velocity.length() < cast_strength:
			prev_pos = pos
			pos = pos + velocity + _gravity * delta * delta
			magnet_area.position = pos
			queue_redraw()
		else:
			if magnet_sprite.visible:
				splash.emitting = true
				magnet_sprite.visible = false
	else:
		var velocity: Vector2 = prev_pos - pos
		if velocity.length() > 1.0:
			if magnet_sprite.visible == false:
				magnet_sprite.visible = true
			pos = prev_pos
			prev_pos = prev_pos + velocity + _gravity * delta * delta
			magnet_area.position = prev_pos
			queue_redraw()
			print("Velocity: ", velocity.length())
		else:
			if is_returning:
				is_returning = false
				return_finished.emit()
			if z_index != ORDER_INDEX_DEFAULT:
				z_index = ORDER_INDEX_DEFAULT


func cast(strength: float, _min: float, _max: float) -> void:
	z_index = ORDER_INDEX_LINECAST

	cast_strength = remap(strength, _min, _max, MIN_LINE_LENGTH, MAX_LINE_LENGTH)
	print()
	print("strength: ", strength)
	print("cast_strength: ", cast_strength)
	cast_line = true
	is_returning = false
	cast_line_timer.start()


func _draw() -> void:
	draw_line(hand_position.position, pos, rope_highlight_color, 1.75)
	draw_line(hand_position.position, pos, rope_outline_color, 1.2)
	draw_line(hand_position.position, pos, rope_color, .6)


func _on_cast_timer_timeout() -> void:
	print("BEGIN PULL")
	cast_line = false
	is_returning = true
	return_started.emit()


func _on_area_enter(area: Area2D) -> void:
	print(area)
	if area is Item:
		print(area.name)
