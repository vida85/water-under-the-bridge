class_name Player extends CharacterBody2D

signal cast_line
signal cast_line_timeout
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
	cast_line_timeout.connect(cast_bar_ui.resume_cast_bar)
	platformer_input_component.cast_magnet_request.connect(_on_cast_line_request)
	magnet.cast_line_timer.timeout.connect(_on_cast_line_timeout)
	magnet.return_started.connect(pull)
	magnet.return_finished.connect(end_pull)


func aim():
	aiming = true
	animation_player.play("aim")


func throw():
	aiming = false
	throwing = true


func end_throw():
	throwing = false
	fishing = true
	player_cast()


func end_pull():
	pulling = false


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
		animation_player.play("fish")
	else:
		animation_player.play("idle")


func _on_cast_line_request() -> void:
	platformer_input_component.turn_all_mobility_inputs_off()

	if cast_bar_ui.is_processing() and cast_bar_ui.visible:
		set_cast_bar.emit()
		_strength = cast_bar_ui.get_cast_bar_set_position()
		#play_cast_line_animation()
		throw()

	elif cast_bar_ui.visible == false:
		aim()
		cast_bar_ui.visible = true

func player_cast():
	is_line_cast = true
	magnet.cast(_strength, cast_bar_ui.BOTTOM, cast_bar_ui.TOP)
	cast_line.emit() # whomever needs to know (UI)

#func play_cast_line_animation():
	#if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
		#animated_sprite.animation_finished.connect(_on_animation_finished)
	#animated_sprite.play("cast_line")

#func _on_animation_finished() -> void:
	#is_line_cast = true
	#animated_sprite.animation_finished.disconnect(_on_animation_finished)
	#magnet.cast(_strength, cast_bar_ui.BOTTOM, cast_bar_ui.TOP)
	#cast_line.emit() # whomever needs to know (UI)


func _on_cast_line_timeout() -> void:
	is_line_cast = false
	cast_bar_ui.hide()
	cast_line_timeout.emit() # whomever needs to know (UI)

	# wait for quick "pull" animation to finish
	# before allowing character movement
	await get_tree().create_timer(.75).timeout
	platformer_input_component.turn_all_mobility_inputs_on()


func on_item_area_entered(_area: Area2D) -> void:
	pass
