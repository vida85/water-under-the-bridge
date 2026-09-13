@tool
extends EditorPlugin

const Convertor = preload("res://addons/AS2P/InspectorConvertor.gd")

var inspector_plugin: Convertor


func _enter_tree() -> void:
	inspector_plugin = Convertor.new()
	inspector_plugin.animation_updated.connect(_refresh, CONNECT_DEFERRED)
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)


## Jump the editor to the AnimationPlayer that was just filled in.
## Doubles as the refresh, since the animation panel won't update
## until the player is reselected.
func _refresh(anim_player: AnimationPlayer) -> void:
	await get_tree().process_frame

	if not is_instance_valid(anim_player):
		return

	var selection := EditorInterface.get_selection()
	selection.clear()
	selection.add_node(anim_player)
	EditorInterface.edit_node(anim_player)
