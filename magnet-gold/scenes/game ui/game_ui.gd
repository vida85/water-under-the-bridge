class_name GameUi extends CanvasLayer

const MINI_GAME = preload("uid://gs8a2y3mtplm")


@export_group("Dependencies")
@export var popup: PopUp

var mini_game_popup: MiniGame

func _ready() -> void:
	pass


func setup_minigame(items: Array) -> void:
	print("Items to show in mini game: ", items)
	mini_game_popup = MINI_GAME.instantiate() as MiniGame
	mini_game_popup.items = items
	add_child(mini_game_popup)


func hide_mini_game() -> void:
	if mini_game_popup:
		mini_game_popup.queue_free()
		mini_game_popup = null
