class_name IndicatorButton extends Button

const INDICATOR_TEXTURE: Texture2D = preload("uid://btbtfekk1yv6w")

var focus_indicator: TextureRect


func _ready() -> void:
	size_flags_horizontal = SIZE_FILL | SIZE_EXPAND

	focus_indicator = TextureRect.new()
	focus_indicator.texture = INDICATOR_TEXTURE
	focus_indicator.visible = false
	focus_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_indicator.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	focus_indicator.anchor_top = 0.5
	focus_indicator.anchor_bottom = 0.5
	focus_indicator.offset_left = 4.0
	focus_indicator.offset_right = 8.0
	focus_indicator.offset_top = -3.0
	focus_indicator.offset_bottom = 3.0
	add_child(focus_indicator)

	mouse_entered.connect(_update_indicator)
	focus_entered.connect(_update_indicator)
	mouse_exited.connect(_update_indicator)
	focus_exited.connect(_update_indicator)


func _update_indicator() -> void:
	focus_indicator.visible = has_focus() or is_hovered()
