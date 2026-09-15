class_name Item extends Area2D


@export var item_resource: ItemResource


func setup() -> void:
	var item_sprite: Sprite2D = Sprite2D.new()
	var collision: CollisionShape2D = CollisionShape2D.new()
	var _shape: Shape2D = CircleShape2D.new()

	_shape.radius = item_resource.caught_radius
	collision.shape = CircleShape2D.new()
	item_sprite.texture = item_resource.texture
	name = item_resource.name
	add_child(item_sprite)
