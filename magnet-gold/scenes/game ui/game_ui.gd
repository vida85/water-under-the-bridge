class_name GameUi extends CanvasLayer

signal minigame_ended
signal turn_off_player_mobility
signal turn_on_player_mobility
signal leave_shop
signal can_cast(value: bool)

const MINI_GAME_V2 = preload("uid://py3j8cf40f4h")


@export_group("Dependencies")
@export var popup_items_caught: PopUp
@export var shop: Shop


var mini_game_popup: MiniGamev2
var minigame_caught_nothing: bool = false


func _ready() -> void:
	popup_items_caught.go_to_shop.connect(go_to_shop_scene)
	popup_items_caught.keep_fishing.connect(turn_on_player)

	minigame_ended.connect(display_items_caught)


func setup_minigame(items: Array) -> void:
	mini_game_popup = MINI_GAME_V2.instantiate() as MiniGamev2

	# Property Injection
	mini_game_popup.items = items

	mini_game_popup.minigame_caught_nothing.connect(_on_minigame_caught_nothing)
	mini_game_popup.minigame_ended.connect(kill_mini_game)
	mini_game_popup.all_items_acquired.connect(popup_items_caught.populate_scroll_container)
	add_child(mini_game_popup)


func kill_mini_game() -> void:
	if mini_game_popup:
		minigame_ended.emit()
		mini_game_popup.queue_free.call_deferred()
		mini_game_popup = null


func _on_minigame_caught_nothing() -> void:
	minigame_caught_nothing = true
	turn_on_player()
	can_cast.emit(true)


func display_items_caught() -> void:
	if minigame_caught_nothing:
		minigame_caught_nothing = false
		return

	turn_off_player_mobility.emit()
	await get_tree().create_timer(.75).timeout
	popup_items_caught.show()


func turn_on_player() -> void:
	turn_on_player_mobility.emit()


func go_to_shop_scene() -> void:
	shop.leave_button.pressed.connect(_on_leave_button)
	shop.show_inventory()
	shop.show.call_deferred()


func _on_leave_button() -> void:
	leave_shop.emit()
	can_cast.emit(true)
