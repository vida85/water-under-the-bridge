class_name Magnet extends Node2D

@export_group("Rope")
@export var point_count: int = 16
@export var segment_length: float = 14.0
@export var gravity: float = 900.0
@export var damping: float = 0.99
@export var iterations: int = 12

@export_group("Casting")
@export var max_cast_speed: float = 1400.0
@export var water_level: Marker2D
@export var retract_speed: float = 600.0

@onready var cast_line_timer: Timer = %CastLineTimer
@onready var line: Line2D = $Line2D
@onready var magnet_area: Area2D = %MagnetArea
@onready var hand_position: Marker2D = %HandPosition


var pos: Vector2
var prev_pos: Vector2
var _gravity: Vector2 = Vector2(0, 600)

var cast_line: bool = false


func _ready() -> void:
	pos = position
	prev_pos = position
	cast_line_timer.timeout.connect(_on_cast_timer_timeout)


func cast(_strength: float, _direction: Vector2) -> void:
	cast_line = true
	cast_line_timer.start()


func _physics_process(delta: float) -> void:
	if cast_line:
		var velocity: Vector2 = pos - prev_pos
		prev_pos = pos
		pos = pos + velocity + _gravity * delta * delta
		magnet_area.position = pos
		queue_redraw()


func _draw() -> void:
	draw_line(position, pos, Color.BLACK, 3.0)


func _on_cast_timer_timeout() -> void:
	cast_line = false
	pos = position
	prev_pos = position
	magnet_area.position = position
	queue_redraw.call_deferred()
