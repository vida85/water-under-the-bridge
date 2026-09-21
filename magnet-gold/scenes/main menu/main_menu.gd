class_name MainMenu extends Control

@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton

@onready var options_popup: PanelContainer = %OptionsPopup
@onready var leave_button: Button = %LeaveButton

@onready var volume_h_slider: HSlider = %VolumeHSlider
@onready var sfx_h_slider: HSlider = %SfxHSlider

@onready var sfx_preview: AudioStreamPlayer = %SfxPreview


const INTRO = preload("res://scenes/intro/Intro.tscn")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GameState.reset()
	options_popup.hide()

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	leave_button.pressed.connect(_on_leave_options_pressed)

	volume_h_slider.value_changed.connect(_on_volume_drag_ended)
	sfx_h_slider.value_changed.connect(_on_sfx_drag_ended)
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
	var alpha: float = 1.0 if interactive else 0.0
	play_button.modulate.a = alpha
	options_button.modulate.a = alpha
	_lock_main_buttons(not interactive)


func _lock_main_buttons(locked: bool) -> void:
	# disabled alone blocks both mouse and keyboard activation; also toggling
	# mouse_filter here was found to leave clicks undetected after unlocking,
	# even though the property correctly reports MOUSE_FILTER_STOP afterward.
	for button: Button in [play_button, options_button]:
		button.disabled = locked
		button.focus_mode = Control.FOCUS_NONE if locked else Control.FOCUS_ALL


func _on_volume_drag_ended(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_sfx_drag_ended(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sfx"), value)
	sfx_preview.play()
