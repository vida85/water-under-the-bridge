@tool
extends EditorProperty
## Inspector property for choosing which AnimationPlayer to export into
## (or creating a new one), and handles the animation export process.

## Item 0 in the dropdown is always "Create new AnimationPlayer".
## Existing players occupy items 1..n, mapping to _players[index - 1].
##
## NOTE: this deliberately uses item INDEX rather than item ID.
## OptionButton.add_item() treats an id of -1 as "no id given" and silently
## substitutes the item's index, so -1 can't be used as a sentinel.
const CREATE_NEW_INDEX := 0

signal animation_updated(anim_player: AnimationPlayer)

var animated_sprite: AnimatedSprite2D
var drop_down := OptionButton.new()

var replace := false

var _players: Array[AnimationPlayer] = []


func _init(_animated_sprite: AnimatedSprite2D) -> void:
	animated_sprite = _animated_sprite

	drop_down.clip_text = true
	# Add the control as a direct child of the EditorProperty node.
	add_child(drop_down)
	# Make sure the control is able to retain focus.
	add_focusable(drop_down)


func _ready() -> void:
	refresh_items()


func set_override(_replace: bool) -> void:
	replace = _replace


# =============================
# SCENE SCANNING
# =============================
func _find_animation_players(root: Node) -> Array[AnimationPlayer]:
	var found: Array[AnimationPlayer] = []

	if root is AnimationPlayer:
		found.append(root)

	for child in root.get_children():
		found.append_array(_find_animation_players(child))

	return found


func refresh_items() -> void:
	drop_down.clear()
	_players.clear()

	drop_down.add_item("Create new AnimationPlayer")

	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_root != null:
		_players = _find_animation_players(scene_root)

		for player in _players:
			drop_down.add_item(String(scene_root.get_path_to(player)))

	drop_down.select(CREATE_NEW_INDEX)

	# Nothing to choose between — don't show a one-option dropdown.
	visible = not _players.is_empty()
	if _players.is_empty():
		return

	# If a sibling AnimationPlayer already exists, default to it —
	# that's almost always the one you meant.
	var parent := animated_sprite.get_parent()
	if parent == null:
		return

	for i in _players.size():
		if _players[i].get_parent() == parent:
			drop_down.select(i + 1)
			return


# =============================
# TARGET RESOLUTION
# =============================
func _resolve_target_player() -> AnimationPlayer:
	var index := drop_down.selected

	if index <= CREATE_NEW_INDEX:
		return _create_animation_player()

	var player_index := index - 1
	if player_index >= _players.size() or not is_instance_valid(_players[player_index]):
		push_warning("[AS2P] The selected AnimationPlayer no longer exists.")
		return null

	return _players[player_index]


## Creates an AnimationPlayer as a sibling directly below the AnimatedSprite2D.
## Registered with the editor's undo history, so Ctrl+Z removes it again.
func _create_animation_player() -> AnimationPlayer:
	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_root == null:
		push_warning("[AS2P] No scene is currently open.")
		return null

	var parent := animated_sprite.get_parent()
	if parent == null:
		push_warning("[AS2P] This AnimatedSprite2D is the scene root — it needs a parent first.")
		return null

	var anim_player := AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"

	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("AS2P: Create AnimationPlayer")
	undo_redo.add_do_method(parent, "add_child", anim_player, true)
	undo_redo.add_do_method(parent, "move_child", anim_player, animated_sprite.get_index() + 1)
	# owner is what makes the node save with the scene. It can only be set
	# once the node is already in the tree, hence the ordering here.
	undo_redo.add_do_property(anim_player, "owner", scene_root)
	undo_redo.add_do_reference(anim_player)
	undo_redo.add_undo_method(parent, "remove_child", anim_player)
	undo_redo.commit_action()

	return anim_player


# =============================
# EXPORT
# =============================
func convert_sprites() -> void:
	var sprite_frames := animated_sprite.sprite_frames
	if sprite_frames == null:
		push_warning("[AS2P] This AnimatedSprite2D has no SpriteFrames!")
		return

	var anim_player := _resolve_target_player()
	if anim_player == null:
		return

	# Track paths are relative to the AnimationPlayer's Root Node, not the player.
	var anim_root := anim_player.get_node_or_null(anim_player.root_node)
	if anim_root == null:
		push_warning("[AS2P] The AnimationPlayer's Root Node is not valid!")
		return

	var sprite_path := anim_root.get_path_to(animated_sprite)
	var count := 0

	for anim in sprite_frames.get_animation_names():
		var frame_count := sprite_frames.get_frame_count(anim)
		var fps := sprite_frames.get_animation_speed(anim)
		var looping := sprite_frames.get_animation_loop(anim)

		if add_animation(anim_player, sprite_path, anim, frame_count, fps, looping):
			count += 1

	print("[AS2P] %s %d animations!" % ["Replaced" if replace else "Added", count])

	refresh_items()
	animation_updated.emit(anim_player)


func add_animation(
	anim_player: AnimationPlayer,
	sprite_path: NodePath,
	anim_name: String,
	frame_count: int,
	fps: float,
	looping: bool
) -> bool:
	if fps <= 0.0 or frame_count <= 0:
		push_warning("[AS2P] '%s' has no frames or an invalid FPS, skipping." % anim_name)
		return false

	var library := _get_default_library(anim_player)

	if library.has_animation(anim_name):
		if not replace:
			return false
		library.remove_animation(anim_name)

	var spf := 1.0 / fps

	var animation := Animation.new()
	animation.length = spf * frame_count
	animation.loop_mode = Animation.LOOP_LINEAR if looping else Animation.LOOP_NONE

	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, "%s:frame" % sprite_path)
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)

	var anim_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(anim_track, "%s:animation" % sprite_path)
	animation.value_track_set_update_mode(anim_track, Animation.UPDATE_DISCRETE)
	animation.track_insert_key(anim_track, 0.0, anim_name)

	for i in frame_count:
		animation.track_insert_key(frame_track, i * spf, i)

	library.add_animation(anim_name, animation)
	return true


## Godot 4 stores animations in AnimationLibrary resources.
## The default library uses an empty string as its key.
func _get_default_library(anim_player: AnimationPlayer) -> AnimationLibrary:
	if anim_player.has_animation_library(""):
		return anim_player.get_animation_library("")

	var library := AnimationLibrary.new()
	anim_player.add_animation_library("", library)
	return library
