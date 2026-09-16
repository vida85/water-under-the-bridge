class_name MagnetFishing extends Node2D

@export var player: Player
@onready var game_ui: GameUi = %GameUi


func _ready() -> void:
	Engine.time_scale = 0.1
	pass


func _process(_delta: float) -> void:
	pass
