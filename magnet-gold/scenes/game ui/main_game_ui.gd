class_name MainGameUi extends Control

@onready var cash_label: Label = %CashLabel
@onready var input_hint_label: RichTextLabel = %InputHintLabel


func _ready() -> void:
	GameState.cash_value_changed.connect(update_cash)


func update_cash(value: float) -> void:
	cash_label.text = "$ " + str(round(value))


func set_input_hint_visible(value: bool) -> void:
	input_hint_label.visible = value
 
