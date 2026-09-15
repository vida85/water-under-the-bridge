class_name CastBar extends Node2D


@onready var bar: Sprite2D = %Bar


const TOP: float = -14.0
const BOTTOM: float = 0.0

var step: float = .1 # how fast the bar moves up and down
var _cast_bar_set_position: int


func _ready() -> void:
	hide()


func _process(_delta: float) -> void:
	if round(bar.position.y) == BOTTOM:
		step = -.1
	elif round(bar.position.y) == TOP:
		step = .1
	bar.position.y += step


func update_bar_speed(value: float) -> void:
	step = value


func pause_cast_bar() -> void:
	set_process(false)
	_cast_bar_set_position = int(bar.position.y)


func resume_cast_bar() -> void:
	set_process(true)


func get_cast_bar_set_position() -> float:
	return _cast_bar_set_position
