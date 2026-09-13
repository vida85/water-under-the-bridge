@tool
extends EditorInspectorPlugin

const NodeSelectorProperty = preload("res://addons/AS2P/NodeSelectorProperty.gd")

signal animation_updated(animation_player: AnimationPlayer)

var node_selector: NodeSelectorProperty

# Properties
var animated_sprite: AnimatedSprite2D

# Options
var replace := false


func _can_handle(object: Object) -> bool:
	if object is AnimatedSprite2D:
		animated_sprite = object
		return true
	return false


func _parse_end(_object: Object) -> void:
	# --- Header ---
	add_custom_control(_make_header("Export to AnimationPlayer"))

	# --- Target dropdown ---
	node_selector = NodeSelectorProperty.new(animated_sprite)
	node_selector.label = "Target"
	node_selector.tooltip_text = (
		"AnimationPlayer to export frames into, or create a new one "
		+ "as a sibling directly below this node."
	)
	node_selector.animation_updated.connect(_on_animation_updated, CONNECT_DEFERRED)

	add_custom_control(node_selector)

	# --- Replace toggle ---
	var replace_option := EditorProperty.new()
	replace_option.label = "Replace"
	replace_option.tooltip_text = "If true, replace existing animations."

	var replace_check := CheckBox.new()
	replace_check.button_pressed = replace
	node_selector.replace = replace
	replace_check.toggled.connect(_on_replace_set)
	replace_check.toggled.connect(node_selector.set_override)
	replace_option.add_child(replace_check)

	add_custom_control(replace_option)

	# --- Export button ---
	var button := Button.new()
	button.text = "Export Animations"
	button.custom_minimum_size.y = 26
	button.button_down.connect(node_selector.convert_sprites)

	add_custom_control(button)


## Pulls its color from the editor theme so it doesn't clash with custom themes.
func _make_header(text: String) -> Label:
	var editor_theme := EditorInterface.get_editor_theme()

	var style := StyleBoxFlat.new()
	if editor_theme and editor_theme.has_color("dark_color_2", "Editor"):
		style.bg_color = editor_theme.get_color("dark_color_2", "Editor")
	else:
		style.bg_color = Color8(64, 69, 83)
	style.content_margin_top = 4
	style.content_margin_bottom = 4

	var header := Label.new()
	header.add_theme_stylebox_override("normal", style)
	header.custom_minimum_size.y = 25
	header.text = text
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	return header


func _on_replace_set(new_replace: bool) -> void:
	replace = new_replace


func _on_animation_updated(anim_player: AnimationPlayer) -> void:
	animation_updated.emit(anim_player)
