class_name ConversationPlayer extends Node

signal conversation_started
signal advance_line()
signal conversation_finished


@export var auto_start: bool = false


var _index: int = 0
var is_active: bool = false


func start() -> void:
	# guard against empty conversation / already active, then emit first line
	
	_index += 1
	conversation_started.emit()
	pass


func advance() -> void:
	# step index; emit line_changed, or finish if past the end
	pass


func stop() -> void:
	conversation_finished.emit()


func play_line() -> void:

	advance_line.emit()