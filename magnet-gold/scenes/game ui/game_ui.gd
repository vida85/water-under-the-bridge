class_name GameUi extends CanvasLayer

signal minigame_ended
signal displaying_items_caught
signal displaying_items_caught_hide


const MINI_GAME = preload("uid://gs8a2y3mtplm")


@export_group("Dependencies")
@export var popup_items_caught: PopUp


var mini_game_popup: MiniGame



func _ready() -> void:
	popup_items_caught.keep_fishing.connect(display_items_caught_hide)
	minigame_ended.connect(display_items_caught)


func setup_minigame(items: Array) -> void:
	mini_game_popup = MINI_GAME.instantiate() as MiniGame
	mini_game_popup.items = items
	mini_game_popup.minigame_ended.connect(kill_mini_game)
	add_child(mini_game_popup)


func kill_mini_game() -> void:
	if mini_game_popup:
		minigame_ended.emit()
		mini_game_popup.queue_free()
		mini_game_popup = null


func display_items_caught() -> void:
	displaying_items_caught.emit()
	await get_tree().create_timer(.75).timeout
	popup_items_caught.show()


func display_items_caught_hide() -> void:
	displaying_items_caught_hide.emit()
