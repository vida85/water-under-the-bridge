class_name MiniGame extends Control

signal magnet_is_off_screen
signal all_items_acquired(items: Array[Item])
signal minigame_ended

@export_group("Magnet")
@export var magnet_resource: MagnetResource


@onready var magnet: TextureRect = %Magnet
@onready var magnet_area: Area2D = %MagnetArea
@onready var magnet_collision_shape: CollisionShape2D = %MagnetCollisionShape

@onready var spawn_area: ReferenceRect = %SpawnArea
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

var items: Array
var items_original_locations: Array[Array]
var items_original_parent: Node

# movement
var current_position: Vector2
var new_position: Vector2

var items_acquired: Array[Item]


const COIN_A_ITEM = preload("uid://dxtn2uaofbsdw")
const COIN_B_ITEM = preload("uid://b1cxxu1auayoy")



func _ready() -> void:
	magnet_area.area_entered.connect(_on_area_entered)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_screen_exited)
	update_magnet_type()

	for _freebies in range(10):
		spawn_coins()

	spawn_items.call_deferred()
	

func update_magnet_type() -> void:
	var radius: float = magnet_resource.magnet_influence[GameState.current_magnet]
	var texture: Texture2D = magnet_resource.magnet_textures[GameState.current_magnet]
	magnet.texture = texture
	magnet_collision_shape.shape.radius = radius * 3
	print("Radius of Magnet: ", radius)


func _on_area_entered(area: Area2D) -> void:
	if area is Item:
		items_acquired.append(area)
		print("|----------> Item caught ", area)



func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		current_position = new_position
		new_position.x += -.1
	if Input.is_action_pressed("right"):
		current_position = new_position
		new_position.x += .1

	magnet.position.y -= 10 * delta
	magnet.position.x = lerp(current_position.x, new_position.x, .25)


func _on_screen_exited() -> void:
	all_items_acquired.emit(items_acquired)
	magnet_is_off_screen.emit()


func spawn_coins() -> void:
	var item_control:= Control.new()
	var coin: Item = COIN_A_ITEM.instantiate() if randi_range(0, 1) == 1 else COIN_B_ITEM.instantiate()
	coin.setup(coin)
	coin.item_sprite.scale = Vector2.ONE

	item_control.global_position = get_random_spawn_position()
	item_control.add_child(coin)
	add_child(item_control)


func spawn_items() -> void:
	print()
	print()
	print("Minigame!")
	for item: Item in items:
		# Create control node for Canvas stuff
		# randomize it's location within the UI Reference Rect,
		# add_child to MiniGame, reparent the items to each new canvas item
		var item_control:= Control.new()

		if items_original_parent != item.get_parent():
			items_original_parent = item.get_parent()
		items_original_locations.append([item, item.global_position])

		item.reparent(item_control, false)
		item.item_sprite.scale = Vector2.ONE
		item_control.global_position = get_random_spawn_position()

		add_child(item_control)
		print("Spawned Item: ", item)
	print("Spawned Total: ", items.size())
	print("+++++++++++++++++++++++++")


func get_random_spawn_position() -> Vector2:
	var x: float = randf_range(0,  spawn_area.size.x)
	var y: float = randf_range(0, spawn_area.size.y)

	return spawn_area.global_position + Vector2(x, y)


func _exit_tree() -> void:
	minigame_ended.emit()
	all_items_acquired.emit(items_acquired)
	# compare all items not acquired to the ones acquired 
	# return non acquired items back to the main game.
	print("=========================")
	for idx in range(items.size()):
		var _item: Item = items[idx]
		if _item in items_acquired:
			continue
		else:
			if items_original_locations.is_empty():
				return

			var item: Item = items_original_locations[idx][0]
			var item_location: Vector2 = items_original_locations[idx][1]

			item.reparent(items_original_parent, false)
			item.global_position = item_location
			item.item_sprite.scale = Vector2(.33, .33)

			print("Item returning: ", item)
