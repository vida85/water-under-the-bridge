class_name MainMenu extends Control

@onready var button_container: HBoxContainer = %ButtonContainer
@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton

@onready var options_popup: PanelContainer = %OptionsPopup
@onready var leave_button: Button = %LeaveButton

@onready var volume_h_slider: HSlider = %VolumeHSlider
@onready var sfx_h_slider: HSlider = %SfxHSlider

@onready var sfx_preview: AudioStreamPlayer = %SfxPreview


const INTRO = preload("res://scenes/intro/Intro.tscn")
const STARTUP_INPUT_LOCK_DURATION: float = 0.2



func _ready() -> void:
	options_popup.hide()
	_lock_main_buttons(true)

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	leave_button.pressed.connect(_on_leave_options_pressed)

	volume_h_slider.value_changed.connect(_on_volume_drag_ended)
	sfx_h_slider.value_changed.connect(_on_sfx_drag_ended)

	# Guards against a key/click held over from the previous scene registering
	# on these buttons the instant they become interactive.
	await get_tree().create_timer(STARTUP_INPUT_LOCK_DURATION).timeout
	Input.flush_buffered_events()
	_lock_main_buttons(false)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed.call_deferred(INTRO)


func _on_options_pressed() -> void:
	_set_main_buttons_interactive(false)
	options_popup.show()
	sfx_h_slider.grab_focus()


func _on_leave_options_pressed() -> void:
	options_popup.hide()
	_set_main_buttons_interactive(true)
	options_button.grab_focus()


func _set_main_buttons_interactive(interactive: bool) -> void:
	button_container.modulate.a = 1.0 if interactive else 0.0
	_lock_main_buttons(not interactive)


func _lock_main_buttons(locked: bool) -> void:
	for button: Button in [play_button, options_button]:
		button.disabled = locked
		button.focus_mode = Control.FOCUS_NONE if locked else Control.FOCUS_ALL
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else Control.MOUSE_FILTER_STOP


func _on_volume_drag_ended(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_sfx_drag_ended(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sfx"), value)
	sfx_preview.play()
