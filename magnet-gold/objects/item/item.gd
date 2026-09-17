class_name Item extends Area2D


@export var item_resource: ItemResource
@export var item_shake: CameraShake

# Item needs to exits in Layer 3
const COLLISION_ITEM_LAYER: int = 3

var item_sprite: Sprite2D
var is_debug_on: bool = false



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
	item_shake.add_trauma(.25)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		_debug_mode()


func _debug_mode() -> void:
	is_debug_on = not is_debug_on

	if is_debug_on:
		item_sprite.scale = Vector2.ONE
	else:
		item_sprite.scale = Vector2.ZERO
