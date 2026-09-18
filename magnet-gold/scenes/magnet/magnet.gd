class_name Magnet extends Node2D

signal return_started
signal return_finished
signal splash_emitted
signal ready_for_minigame(items: Array)
signal display_timer(time: int)


@export_group("Rope")
@export var rope_color: Color
@export var rope_outline_color: Color
@export var rope_highlight_color: Color
@export var hand_position: Marker2D

@export_group("Magnet")
@export var magnet_resource: MagnetResource


#@onready var cast_line_timer: Timer = %CastLineTimer
@onready var line: Line2D = $Line2D

@onready var magnet_area: Area2D = %MagnetArea
@onready var magnet_sprite: Sprite2D = %MagnetSprite
@onready var magnet_shape: CollisionShape2D = %MagnetShape

@onready var splash: GPUParticles2D = %Splash

@onready var splash_out: AudioStreamPlayer = %Splash_out
@onready var splash_in: AudioStreamPlayer = %Splash_in


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

var attracted_items: Array:
	set(val):
		attracted_items = val
		ready_for_minigame.emit(attracted_items)


func _ready() -> void:
	hide()
	magnet_area.area_entered.connect(_on_area_enter)
	z_index = ORDER_INDEX_DEFAULT

	pos = hand_position.position
	prev_pos = hand_position.position
	magnet_area.position = hand_position.position

	update_magnet_type()


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
				splash_in.play()
				splash.emitting = true
				splash_emitted.emit()
				magnet_sprite.visible = false

				await get_tree().create_timer(.85).timeout
				attracted_items = magnet_area.get_overlapping_areas()
	else:
		var velocity: Vector2 = prev_pos - pos
		if velocity.length() > 1.0:
			if magnet_sprite.visible == false:
				magnet_sprite.visible = true
				splash_out.play()
			pos = prev_pos
			prev_pos = prev_pos + velocity + _gravity * delta * delta
			magnet_area.position = prev_pos
			queue_redraw()
		else:
			if is_returning:
				is_returning = false
				return_finished.emit()
				hide()
				if z_index != ORDER_INDEX_DEFAULT:
					z_index = ORDER_INDEX_DEFAULT


func _draw() -> void:
	draw_line(hand_position.position, pos, rope_highlight_color, 2.0)


func triger_return_magnet_animation() -> void:
	cast_line = false
	is_returning = true
	return_started.emit()


func _on_area_enter(area: Area2D) -> void:
	if area is Item:
		pass


func cast(strength: float, _min: float, _max: float) -> void:
	z_index = ORDER_INDEX_LINECAST
	show()

	cast_strength = remap(strength, _min, _max, MIN_LINE_LENGTH, MAX_LINE_LENGTH)
	cast_line = true
	is_returning = false

	strength = clamp(abs(strength), abs(_min + 1), abs(_max))
	display_timer.emit(int(strength if strength >= 2.0 else 3.0))


func update_magnet_type() -> void:
	#magnet_sprite.texture = magnet_resource.magnet_textures[GameState.current_magnet]
	magnet_shape.shape.radius = magnet_resource.magnet_influence[GameState.current_magnet]
