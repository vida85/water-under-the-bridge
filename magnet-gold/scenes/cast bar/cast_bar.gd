class_name CastBar extends Node2D


@onready var bar: Sprite2D = %Bar
								   #-2<= -4<= -6<=  -10 <=
const CAST_X_SCALE: Array[float] = [.36, .67, 1.0, 1.333]
const TOP: float = -16.0
const BOTTOM: float = 0.0

var step: float = .1 # how fast the bar moves up and down
var turn_process_back_on: bool = false
var _cast_bar_set_position: int



func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	if turn_process_back_on:
		bar.position.y = BOTTOM
		turn_process_back_on = false

	if round(bar.position.y) == BOTTOM:
		step = -.1
	elif round(bar.position.y) == TOP:
		step = .1
	bar.position.y += step

	if bar.position.y >= -2:
		bar.scale = Vector2(CAST_X_SCALE[0], 1.0)
	elif bar.position.y >= -4:
		bar.scale = Vector2(CAST_X_SCALE[1], 1.0)
	elif bar.position.y >= -6:
		bar.scale = Vector2(CAST_X_SCALE[2], 1.0)
	elif bar.position.y >= -10:
		bar.scale = Vector2(CAST_X_SCALE[3], 1.0)


func update_bar_speed(value: float) -> void:
	step = value


func pause_cast_bar() -> void:
	set_process(false)
	_cast_bar_set_position = int(bar.position.y)


func resume_cast_bar() -> void:
	set_process(true)
	turn_process_back_on = true


func get_cast_bar_set_position() -> float:
	return _cast_bar_set_position
