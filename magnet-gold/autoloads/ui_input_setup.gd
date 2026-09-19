extends Node


func _ready() -> void:
	_add_key_event("ui_up", KEY_W)
	_add_key_event("ui_down", KEY_S)
	_add_key_event("ui_left", KEY_A)
	_add_key_event("ui_right", KEY_D)


func _add_key_event(action: StringName, physical_keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	InputMap.action_add_event(action, event)
