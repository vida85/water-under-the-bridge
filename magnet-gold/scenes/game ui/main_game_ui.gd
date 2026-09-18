class_name MainGameUi extends Control

@onready var cash_label: Label = %CashLabel


func _ready() -> void:
	GameState.update_cash.connect(update_cash)


func update_cash(value: float) -> void:
	cash_label.text = "Cash: $"+str(value)
