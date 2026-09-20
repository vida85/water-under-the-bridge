class_name Item extends Area2D

signal coin_has_faded_and_died


@export var item_resource: ItemResource
@onready var bell_sfx: AudioStreamPlayer2D = %BellSFX

@onready var sparkle_sprite: Sprite2D = %SparkleSprite
@onready var sparkle_ap: AnimationPlayer = %SparkleAP


# Item needs to exits in Layer 3
const COLLISION_ITEM_LAYER: int = 3
const COIN_TRANSITION_TIME: float = .33
const SPARKLE_LARGE = preload("uid://dgoeuhk57gdmf")


var item_sprite: Sprite2D

var tween: Tween
var is_item_stuck_to_magnet: bool


func setup(item: Item) -> void:
	if "heirloom" in item.name.to_lower():
		sparkle_sprite.texture = SPARKLE_LARGE

	item_sprite = Sprite2D.new()
	var collision2D: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()

	shape.radius = item_resource.caught_radius
	collision2D.shape = shape

	name = item_resource.name

	item.set_collision_layer_value(COLLISION_ITEM_LAYER, true)

	item.add_child(collision2D)
	item.add_child(item_sprite)

	sparkle_ap.seek(randf() * sparkle_ap.get_animation("sparkle").length, true)


func show_item_sprite() -> void:
	item_sprite.visible = true
	sparkle_sprite.visible = false


func hide_sparkle() -> void:
	sparkle_sprite.visible = false


func show_sparkle() -> void:
	sparkle_sprite.visible = true


func set_monitorable_monitoring(value: bool) -> void:
	monitorable = value
	monitoring = value


func fade_away(coin_end_position: Marker2D) -> void:
	await get_tree().create_timer(randf()).timeout

	tween = _reset_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, COIN_TRANSITION_TIME)
	await tween.tween_property(self, "global_position", coin_end_position.global_position, COIN_TRANSITION_TIME).finished
	GameState.update_cash(item_resource.value)
	bell_sfx.play()
	await get_tree().create_timer(1.0).timeout
	coin_has_faded_and_died.emit(item_resource.value)


func _reset_tween() -> Tween:
	if tween and tween.is_running():
		tween.kill()
	return create_tween()
