class_name MainMenu extends Control

@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton

@onready var option_volume_container: VBoxContainer = %OptionVolumeContainer
@onready var option_sfx_container: VBoxContainer = %OptionSfxContainer

@onready var volume_h_slider: HSlider = %VolumeHSlider
@onready var sfx_h_slider: HSlider = %SfxHSlider


const MAIN_GAME = preload("uid://brkaifraddpx4")


func _ready() -> void:
	option_volume_container.hide()
	option_sfx_container.hide()

	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)

	volume_h_slider.value_changed.connect(_on_volume_drag_ended)
	sfx_h_slider.value_changed.connect(_on_sfx_drag_ended)
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed.call_deferred(MAIN_GAME)


func _on_options_pressed() -> void:
	option_volume_container.visible = not option_volume_container.visible
	option_sfx_container.visible = not option_sfx_container.visible


func _on_volume_drag_ended(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_sfx_drag_ended(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sfx"), value)
