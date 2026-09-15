class_name MagnetFishing extends Node2D

@export var player: Player
@onready var game_ui: GameUi = %GameUi


func _ready() -> void:
	player.magnet.ready_for_minigame.connect(game_ui.setup_minigame)
	player.magnet.cast_line_timer.timeout.connect(game_ui.hide_mini_game)

func _process(_delta: float) -> void:
	pass
