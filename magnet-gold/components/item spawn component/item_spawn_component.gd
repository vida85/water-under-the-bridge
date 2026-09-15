class_name ItemSpawnComponent extends Node

@export var player: Player
@export var item_spawn_area: ReferenceRect
@export var items: Array[PackedScene]


func _ready() -> void:
	_spawn_items()


func _spawn_items() -> void:
	for _item: PackedScene in items:
		var item: Item = _item.instantiate()
		item.global_position = get_random_spawn_position()
		#item.item_area.area_entered.connect(player.magnet)
		add_child(item)
		item.setup.call_deferred()


func get_random_spawn_position() -> Vector2:
	var x: float = randf_range(0,  item_spawn_area.size.x)
	var y: float = randf_range(0, item_spawn_area.size.y)

	return item_spawn_area.global_position + Vector2(x, y)
