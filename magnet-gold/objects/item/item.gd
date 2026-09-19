class_name Item extends Area2D

signal coin_has_faded_and_died


@export var item_resource: ItemResource
@onready var bell_sfx: AudioStreamPlayer2D = %BellSFX
@onready var splash: GPUParticles2D = %Splash


# Item needs to exits in Layer 3
const COLLISION_ITEM_LAYER: int = 3
const COIN_TRANSITION_TIME: float = .33

var item_sprite: Sprite2D
var is_debug_on: bool = false

var tween: Tween
var is_item_stuck_to_magnet: bool


func setup(item: Item) -> void:
	item_sprite = Sprite2D.new()
	var collision2D: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()

	shape.radius = item_resource.caught_radius
	collision2D.shape = shape
	item_sprite.texture = item_resource.texture
	item_sprite.scale = Vector2.ZERO
	name = item_resource.name

	item.set_collision_layer_value(COLLISION_ITEM_LAYER, true)

	item.add_child(collision2D)
	item.add_child(item_sprite)


func shake_item() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		_debug_mode()


func _debug_mode() -> void:
	is_debug_on = not is_debug_on

	if is_debug_on:
		item_sprite.scale = Vector2.ONE
	else:
		item_sprite.scale = Vector2.ZERO


func fade_away(coin_end_position: Marker2D) -> void:
	splash.global_position = coin_end_position.global_position
	await get_tree().create_timer(randf()).timeout

	tween = _reset_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, COIN_TRANSITION_TIME)
	await tween.tween_property(self, "global_position", coin_end_position.global_position, COIN_TRANSITION_TIME).finished
	GameState.update_cash(item_resource.value)
	bell_sfx.play()
	splash.emitting = true
	await get_tree().create_timer(1.0).timeout
	coin_has_faded_and_died.emit(item_resource.value)


func _reset_tween() -> Tween:
	if tween and tween.is_running():
		tween.kill()
	return create_tween()
