class_name Outro extends Control

# change_scene_to_file(), not preload()+change_scene_to_packed(): MainMenu ->
# Intro -> MainGame -> Outro -> MainMenu is a preload cycle. Since MainMenu.tscn
# is run/main_scene, preloading it here would have it still mid-load higher up
# the same boot-time load chain, so Godot hands back a broken PackedScene and
# instantiate() silently fails. Resolving the path only when this code actually
# runs avoids that entirely, since MainMenu is already fully loaded by then.
const MAIN_MENU_PATH = "uid://cy57xutg2kj7w"

const FADE_DURATION: float = 2.0
const SHOW_DURATION: float = 4.0

@onready var panel: Sprite2D = $Panel1
@onready var end_label: RichTextLabel = %EndLabel

var tween: Tween
var finished_showing: bool = false


func _ready() -> void:
	print("[Outro] _ready")
	end_label.hide()
	panel.modulate.a = 0.0
	_play_sequence()


func _play_sequence() -> void:
	print("[Outro] sequence started")
	tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, FADE_DURATION)
	tween.tween_interval(SHOW_DURATION)
	tween.tween_callback(_show_end_text)


func _show_end_text() -> void:
	print("[Outro] _show_end_text - finished_showing set to true")
	finished_showing = true
	end_label.show()


func _unhandled_input(event: InputEvent) -> void:
	print("[Outro] _unhandled_input event=", event, " finished_showing=", finished_showing)

	var is_press: bool = (event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton) and event.is_pressed()
	if not is_press:
		print("[Outro] ignored: not a press")
		return

	if finished_showing:
		# Accept echo (held-key) events here so exiting isn't blocked by whatever
		# key the player used to trigger/skip the outro still being held down.
		print("[Outro] exiting to main menu")
		var err: Error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
		print("[Outro] change_scene_to_file result=", err)
		return

	if event is InputEventKey and event.echo:
		print("[Outro] ignored: echo during skip phase")
		return

	print("[Outro] skipping to end")
	_skip_to_end()


func _skip_to_end() -> void:
	if tween:
		tween.kill()
	panel.modulate.a = 1.0
	_show_end_text()
