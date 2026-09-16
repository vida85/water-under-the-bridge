class_name ItemSpawnComponent extends Node


@export var player: Player
@export var item_spawn_area: ReferenceRect
@export var items: Array[PackedScene]


func _ready() -> void:
	player.magnet.ready_for_minigame.connect(_on_ready_for_minigame)
	_spawn_items()


func _spawn_items() -> void:
	for _item: PackedScene in items:
		var item: Item = _item.instantiate()
		item.global_position = get_random_spawn_position()
		add_child(item)
		item.setup.call_deferred(item)


func get_random_spawn_position() -> Vector2:
	var x: float = randf_range(0,  item_spawn_area.size.x)
	var y: float = randf_range(0, item_spawn_area.size.y)

	return item_spawn_area.global_position + Vector2(x, y)


func _on_ready_for_minigame(attracted_items: Array) -> void:
	turn_off_items_not_attracted.call_deferred(attracted_items)


func turn_off_items_not_attracted(attracted_items: Array) -> void:
	for item: Item in get_children():
		if item in attracted_items:
			continue
		item.monitorable = false
		item.monitoring = false


func on_minigame_finished() -> void:
	for item: Item in get_children():
		item.monitorable = true
		item.monitoring = true
