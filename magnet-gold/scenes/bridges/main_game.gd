class_name MainGame extends Node2D



@export_group("Dependencies")
@export var player: Player
@export var item_spawn_component: ItemSpawnComponent
@export var main_camera: Camera2D

@onready var game_ui: GameUi = %GameUi


func _ready() -> void:
	game_ui.leave_shop.connect(player.turn_on_player_mobility)
	game_ui.can_cast.connect(player._set_cast_button)

	game_ui.popup_items_caught.can_cast.connect(player._set_cast_button)

	game_ui.minigame_ended.connect(item_spawn_component.on_minigame_finished)
	game_ui.minigame_ended.connect(player.on_cast_line_pull_up)

	game_ui.turn_off_player_mobility.connect(player.turn_off_player_mobility)
	game_ui.turn_on_player_mobility.connect(player.turn_on_player_mobility)

	player.magnet.ready_for_minigame.connect(game_ui.setup_minigame)
	player.magnet.splash_emitted.connect(main_camera.add_shake)
