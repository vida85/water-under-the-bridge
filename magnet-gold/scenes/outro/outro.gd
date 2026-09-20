class_name Outro extends Control

# change_scene_to_file() avoids a preload cycle back to MainMenu (which preloads Intro -> MainGame -> Outro).
const MAIN_MENU_PATH = "uid://cy57xutg2kj7w"

const FADE_DURATION: float = 2.0
const GROW_DURATION: float = FADE_DURATION * 8
const SHOW_DURATION: float = 4.0
const MAX_SCALE: Vector2 = Vector2.ONE * 2

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
	tween.set_parallel()
	tween.tween_property(panel, "scale", MAX_SCALE, GROW_DURATION)
	tween.tween_property(panel, "modulate:a", 1.0, FADE_DURATION)
	tween.set_parallel(false)
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
		# Accept echoed (held-key) events so a still-held trigger key doesn't block exiting.
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
	panel.scale = MAX_SCALE
	_show_end_text()
