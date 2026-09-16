class_name MainGame extends Node2D



@export_group("Dependencies")
@export var player: Player
@export var item_spawn_component: ItemSpawnComponent

@onready var game_ui: GameUi = %GameUi


func _ready() -> void:
	game_ui.minigame_ended.connect(item_spawn_component.on_minigame_finished)
	player.magnet.ready_for_minigame.connect(game_ui.setup_minigame)
	player.magnet.cast_line_timer.timeout.connect(game_ui.hide_mini_game)
