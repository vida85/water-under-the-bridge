class_name MiniGame extends Control

signal magnet_is_off_screen


@export_group("Magnet")
@export var magnet_resource: MagnetResource


@onready var magnet: TextureRect = %Magnet
@onready var spawn_area: ReferenceRect = %SpawnArea
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

var items: Array
var items_original_locations: Array[Vector2]
var items_original_parent: Node

const COIN_A_ITEM = preload("uid://dxtn2uaofbsdw")
const COIN_B_ITEM = preload("uid://b1cxxu1auayoy")



func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(_on_screen_exited)
	update_magnet_type()

	for _freebies in range(10):
		spawn_coins()

	spawn_items.call_deferred()
	

func update_magnet_type() -> void:
	magnet.texture = magnet_resource.magnet_textures[GameState.current_magnet]


func _process(delta: float) -> void:
	magnet.position.y -= 10 * delta


func _on_screen_exited() -> void:
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
	for item: Item in items:
		#TODO: Create something small like a marker 2d for Canvas stuff
		# randomize it's location within the UI add_child to MiniGame
		# reparent the items to each new canvas item
		var item_control:= Control.new()

		if items_original_parent != item.get_parent():
			items_original_parent = item.get_parent()
		items_original_locations.append(item.global_position)

		item.reparent(item_control, false)
		item.item_sprite.scale = Vector2.ONE
		item_control.global_position = get_random_spawn_position()

		add_child(item_control)


func get_random_spawn_position() -> Vector2:
	var x: float = randf_range(0,  spawn_area.size.x)
	var y: float = randf_range(0, spawn_area.size.y)

	return spawn_area.global_position + Vector2(x, y)
