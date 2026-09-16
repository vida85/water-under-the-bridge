class_name Item extends Area2D


@export var item_resource: ItemResource

# Item needs to exits in Layer 3
const COLLISION_ITEM_LAYER: int = 3

var item_sprite: Sprite2D

func setup(item: Item) -> void:
	item_sprite = Sprite2D.new()
	var collision2D: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	#var shape: CircleShape2D = item_collision.shape

	shape.radius = item_resource.caught_radius
	collision2D.shape = shape
	item_sprite.texture = item_resource.texture
	item_sprite.scale = Vector2(.33, .33)
	name = item_resource.name

	item.set_collision_layer_value(COLLISION_ITEM_LAYER, true)

	item.add_child(collision2D)
	item.add_child(item_sprite)
