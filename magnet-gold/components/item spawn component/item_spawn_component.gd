class_name ItemSpawnComponent extends Node


@export var player: Player
@export var item_spawn_area: ReferenceRect
@export var items: Array[PackedScene]


func _ready() -> void:
	player.magnet.ready_for_minigame.connect(_on_ready_for_minigame)
	_spawn_items()


func _on_ready_for_minigame(attracted_items: Array) -> void:
	turn_off_items_not_attracted.call_deferred(attracted_items)


func _spawn_items() -> void:
	for _item: PackedScene in items:
		var item: Item = _item.instantiate()
		item.global_position = get_random_spawn_position()
		add_child(item)
		turn_item_on_off_from_magnet_tier(item)
		item.setup.call_deferred(item)


func _turn_off_item(item: Item) -> void:
	item.set_monitorable_monitoring(false)
	item.hide_sparkle.call_deferred()


func _turn_on_item(item: Item) -> void:
	item.set_monitorable_monitoring(true)
	item.show_sparkle.call_deferred()


func turn_item_on_off_from_magnet_tier(item: Item) -> void:
	var item_magnet_tier: int =  item.item_resource.responds_to_magnet_tier

	if item_magnet_tier == 0 and GameState.current_magnet >= 0:
		_turn_on_item(item)
	elif item_magnet_tier == 1 and GameState.current_magnet >= 1:
		_turn_on_item(item)
	elif item_magnet_tier == 2 and GameState.current_magnet >= 2:
		_turn_on_item(item)
	else:
		_turn_off_item(item)


func get_random_spawn_position() -> Vector2:
	var x: float = randf_range(0,  item_spawn_area.size.x)
	var y: float = randf_range(0, item_spawn_area.size.y)

	return item_spawn_area.position + Vector2(x, y)


func turn_off_items_not_attracted(attracted_items: Array) -> void:
	for item: Item in get_children():
		if item in attracted_items:
			continue
		item.monitorable = false
		item.monitoring = false


func on_event_finished() -> void:
	for item: Item in get_children():
		turn_item_on_off_from_magnet_tier(item)
