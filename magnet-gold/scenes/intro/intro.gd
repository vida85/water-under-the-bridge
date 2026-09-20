class_name Intro extends Control

const HOME_BRIDGE = preload("uid://brkaifraddpx4")

const FADE_DURATION: float = 1.0
const WAIT_DURATION: float = 2.0

@onready var panels: Array[Sprite2D] = [$Panel1, $Panel2, $Panel3, $Panel4]
@onready var continue_label: RichTextLabel = %ContinueLabel

var current_index: int = -1
var tween: Tween
var all_panels_shown: bool = false


func _ready() -> void:
	continue_label.hide()
	for panel in panels:
		panel.modulate.a = 0.0
	_show_next_panel()


func _show_next_panel() -> void:
	current_index += 1
	if current_index >= panels.size():
		_show_continue_prompt()
		return

	tween = create_tween()
	tween.tween_property(panels[current_index], "modulate:a", 1.0, FADE_DURATION)
	tween.tween_interval(WAIT_DURATION)
	tween.tween_callback(_show_next_panel)


func _show_continue_prompt() -> void:
	all_panels_shown = true
	continue_label.show()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return

	var is_press: bool = (event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton) and event.is_pressed()
	if not is_press:
		return

	if all_panels_shown:
		get_tree().change_scene_to_packed.call_deferred(HOME_BRIDGE)
		return

	_skip_to_next_panel()


func _skip_to_next_panel() -> void:
	if tween:
		tween.kill()
	if current_index >= 0 and current_index < panels.size():
		panels[current_index].modulate.a = 1.0
	_show_next_panel()
