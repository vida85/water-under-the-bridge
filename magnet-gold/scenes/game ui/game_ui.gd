class_name GameUi extends CanvasLayer

signal minigame_ended
const MINI_GAME = preload("uid://gs8a2y3mtplm")


@export_group("Dependencies")
@export var popup_items_caught: PopUp


var mini_game_popup: MiniGame



func _ready() -> void:
	minigame_ended.connect(display_items_caught)


func setup_minigame(items: Array) -> void:
	mini_game_popup = MINI_GAME.instantiate() as MiniGame
	mini_game_popup.items = items
	mini_game_popup.minigame_ended.connect(func(): minigame_ended.emit())
	add_child(mini_game_popup)


## Called from a signal in magnet.CastLineTimer.timeout
func hide_mini_game() -> void:
	if mini_game_popup:
		mini_game_popup.queue_free()
		mini_game_popup = null


func display_items_caught() -> void:
	popup_items_caught.show()
