class_name MiniGamev2 extends Node2D


signal all_items_acquired(items: Array[Item])
signal minigame_ended
signal minigame_caught_nothing


@export_group("Magnet")
@export var magnet_resource: MagnetResource


@onready var magnet: Sprite2D = %Magnet
@onready var magnet_area: Area2D = %MagnetArea
@onready var magnet_collision_shape: CollisionShape2D = %MagnetCollisionShape

@onready var spawn_area: ReferenceRect = %SpawnArea
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D
@onready var item_container: Node2D = %ItemContainer
@onready var magnet_start_position: Marker2D = %MagnetStartPosition
@onready var coin_end_position: Marker2D = %CoinEndPosition

@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var magnet_sfx: AudioStreamPlayer2D = %MagnetSFX
@onready var cash_sfx: AudioStreamPlayer2D = %CashSFX
@onready var magnet_slide_sfx: AudioStreamPlayer2D = %MagnetSlideSFX
@onready var bell_sfx: AudioStreamPlayer2D = %BellSFX

@onready var coin_colection_area: Area2D = %CoinColectionArea

const NEW_SHADER_SHINE_MATERIAL = preload("uid://ce4ndjmb4u3kf")


var coins: Array
var items: Array
var items_original_locations: Array[Array]
var items_original_parent: Node

# movement
var current_position: Vector2
var new_position: Vector2

var items_acquired: Array[Item]
var magnet_speed: float = 10.0


const COIN_A_ITEM = preload("uid://dxtn2uaofbsdw")
const COIN_B_ITEM = preload("uid://b1cxxu1auayoy")

## drag is a divider which controls the coin's acceleration and the time it takes
## to change direction. A higher value makes it less reactive.
const DRAG: float = 25.0
var drag: float = DRAG
var max_speed: float = 300.0
var _velocity: Vector2 = Vector2.ZERO
var _quick_pull: bool = false


var _total_coins_acquired: float = 0.0:
	set(val):
		_total_coins_acquired = val
		GameState.current_money_earned += _total_coins_acquired


func _ready() -> void:
	coin_colection_area.area_entered.connect(_on_magnet_entered)
	_turn_off_items()
	animation_player.play("popup")
	_update_magnet_type_from_resource()
	magnet_area.global_position = magnet_start_position.global_position
	set_process(false)
	set_physics_process(false)


func _update_magnet_type_from_resource() -> void:
	var radius: float = magnet_resource.magnet_influence[GameState.current_magnet]
	var texture: Texture2D = magnet_resource.magnet_textures[GameState.current_magnet]
	magnet.texture = texture
	magnet.z_index = -1
	magnet_collision_shape.shape.radius = radius * 3
	print("Radius of Magnet: ", radius)


func _turn_off_items() -> void:
	for item: Item in items:
		item.monitorable = false
		item.monitoring = false


func _turn_on_items() -> void:
	for item: Item in items:
		item.monitorable = true
		item.monitoring = true


func _on_area_entered(area: Area2D) -> void:
	if area is Item and not _quick_pull:
		var item: Item = area
		if not magnet_sfx.playing:
			magnet_sfx.play.call_deferred()

		if "coin" in item.item_resource.name.to_lower():
			coins.append(item)
			item.set_deferred("monitorable", false)

			# After a small amount let item get stuck to magnet 
			await get_tree().create_timer(2.0).timeout
			item.is_item_stuck_to_magnet = true
			item.reparent(magnet_area)

		if item not in coins:
			items_acquired.append.call_deferred(item)

		if items_acquired.is_empty():
			return

		drag = DRAG * items_acquired.size()
		print("|----------> Item caught ", item)


func _on_coin_faded_away(value: float) -> void:
	_total_coins_acquired += value


func _on_area_exited(area: Area2D) -> void:
	if area is Item and not _quick_pull:
		if "coin" in area.item_resource.name.to_lower():
			return

		if is_instance_valid(area):
			items_acquired.erase.call_deferred(area)
			print("|----------> Item lost ", area)


func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		current_position = new_position
		new_position.x += -.125
	if Input.is_action_pressed("right"):
		current_position = new_position
		new_position.x += .125

	if Input.is_action_pressed("pull_up_quickly"):
		_quick_pull = true
		magnet_speed += 12.5

	magnet_area.position.y -= magnet_speed * delta
	magnet_area.position.x = lerp(current_position.x, new_position.x, .25)


func _physics_process(delta: float) -> void:
	var item: Item
	var desired_velocity := Vector2.ZERO

	# Magnet attraction logic ITEMS
	for idx in range(items_acquired.size()):
		item = items_acquired[idx]
		desired_velocity = max_speed * item.global_position.direction_to(magnet_area.position)
		var steering := desired_velocity - _velocity
		_velocity += steering / drag
		item.translate(_velocity * delta)

	desired_velocity = Vector2.ZERO
	# Magnet attraction logic COINS
	for idx in range(coins.size()):
		item = coins[idx]
		if not item.is_item_stuck_to_magnet:
			desired_velocity = max_speed * item.global_position.direction_to(magnet_area.position)
			var steering := desired_velocity - _velocity
			_velocity += steering / drag
			item.translate(_velocity * delta)


func _on_magnet_entered(_area: Area2D) -> void:
	bell_sfx.play()
	for coin: Item in coins:
		if items_acquired.has(coin):
			items_acquired.erase.call_deferred(coin)
		coin.fade_away(coin_end_position)

  
func _on_screen_exited() -> void:
	await get_tree().create_timer(1.0 if not _quick_pull else 2.0).timeout
	if items_acquired.is_empty():
		minigame_caught_nothing.emit.call_deferred()
	else:
		all_items_acquired.emit.call_deferred(items_acquired)

	minigame_ended.emit.call_deferred()


func _exit_tree() -> void:
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
			item.item_sprite.scale = Vector2.ZERO if !item.is_debug_on else Vector2.ONE

			print("Item returning: ", item)
	items.clear()


func spawn_coins() -> void:
	var item_control:= Sprite2D.new()
	var coin: Item = COIN_A_ITEM.instantiate() if randi_range(0, 1) == 1 else COIN_B_ITEM.instantiate()
	coin.setup(coin)
	coin.item_sprite.scale = Vector2.ONE
	coin.coin_has_faded_and_died.connect(_on_coin_faded_away)

	item_control.global_position = get_random_spawn_position()
	item_control.add_child(coin)
	item_container.add_child(item_control)


func spawn_items() -> void:
	print()
	print()
	print("Minigame!")
	for item: Item in items:
		# Create control node for Canvas stuff
		# randomize it's location within the UI Reference Rect,
		# add_child to MiniGame, reparent the items to each new canvas item
		var item_control:= Sprite2D.new()

		if items_original_parent != item.get_parent():
			items_original_parent = item.get_parent()

		items_original_locations.append([item, item.global_position])
		print("Before Reparent")
		print("item.global_position = ", item.global_position, "\nitem.position = ", item.position)
		item.reparent(item_control, false)
		item.position = Vector2.ZERO
		item.global_position = Vector2.ZERO
		print("After Reparent")
		print("item.global_position = ", item.global_position, "\nitem.position = ", item.position)
		item.item_sprite.scale = Vector2.ONE
		item.item_sprite.material = NEW_SHADER_SHINE_MATERIAL
		item.shake_item()

		item_control.position = get_random_spawn_position()

		item_container.add_child(item_control)
		print("Spawned Item: ", item, "position = ", item.global_position, "global_position = ", item.global_position)
	print("Spawned Total: ", items.size())
	print("+++++++++++++++++++++++++")


func get_random_spawn_position() -> Vector2:
	var x: float = randf_range(0,  spawn_area.size.x)
	var y: float = randf_range(0, spawn_area.size.y)

	return spawn_area.position + Vector2(x, y)

## Called from animation_player after animation_player.play("popup") finished
func begin_mini_game() -> void:
	spawn_items.call_deferred()
	items_acquired.clear()

	for _freebies in range(randi_range(1, 9)):
		spawn_coins()

	current_position = magnet_area.position
	new_position = current_position
	visible_on_screen_notifier_2d.screen_exited.connect(_on_screen_exited)
	magnet_area.area_exited.connect(_on_area_exited)
	magnet_area.area_entered.connect(_on_area_entered)
	set_process(true)
	set_physics_process(true)
	_turn_on_items()
	magnet_slide_sfx.play()
