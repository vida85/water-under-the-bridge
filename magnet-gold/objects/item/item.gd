class_name Item extends Area2D


@export var item_resource: ItemResource
@export var item_shake: CameraShake

# Item needs to exits in Layer 3
const COLLISION_ITEM_LAYER: int = 3
# DRAG is a divider which controls the coin's acceleration and the time it takes
# to change direction. A higher value makes it less reactive.
const DRAG := 14.0

var max_speed := 400.0

var _velocity := Vector2.ZERO
var item_sprite: Sprite2D
var is_debug_on: bool = false

var magnet_area: Area2D = null:
	set(val):
		magnet_area = val
		if magnet_area:
			magnet_area_active = true
		else:
			magnet_area_active = false

var magnet_area_active: bool = false


func setup(item: Item) -> void:
	item_sprite = Sprite2D.new()
	var collision2D: CollisionShape2D = CollisionShape2D.new()
	var shape: CircleShape2D = CircleShape2D.new()
	#var shape: CircleShape2D = item_collision.shape

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


func _physics_process(delta: float) -> void:
	if magnet_area_active:
		# We detect attractors using `get_overlapping_areas()`
		var items: Array = magnet_area.get_overlapping_areas()
		print("Items overlapping_area: ", items)
		if items.is_empty():
			return

		var desired_velocity := Vector2.ZERO
		# If there is one or more overlapping areas, we steer towards the first one.

		# The desired velocity is a vector of length `max_speed` pointing
		# towards the player.
		desired_velocity = max_speed * global_position.direction_to(items[0].global_position)

		# The follow steering equation works like so:
		#
		# 1. We calculate the difference between the desired and current
		#    velocity.
		# 2. We add a fraction of that difference to the current velocity.
		var steering := desired_velocity - _velocity
		_velocity += steering / DRAG
		translate(_velocity * delta)
