@tool
@icon("res://addons/juicebox_pro/icons/icon_animator.png")
class_name JuiceAnimator
extends Node

## List of available animations for this component.
@export var animations: Array[JuiceAnimation] = []

@export_group("Playback")
@export var autoplay: String = "idle"
@export var current_animation: String = ""
@export var speed_scale: float = 1.0
## If -1, plays all frames linearly. 
## If >= 0, restricts playback to this specific row (useful for directional spritesheets).
@export var view_row_index: int = -1

@export_group("Directional Settings")
## Maps the standard direction index (0=East, 1=SE... 7=NE) to the actual Sprite Sheet Row.
## If empty, it assumes standard order (Row 0=East, Row 1=SE, etc.)
@export var direction_map: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7]


@export_group("Editor Tools")
@export var preview_in_editor: bool = false
@export var test_animation: String = "idle"
@export var trigger_test: bool = false:
	set(value):
		if value: # Fixed the invisible character error here
			play(test_animation)
		trigger_test = false

var parent: Sprite2D 
var _active_anim: JuiceAnimation = null
var _frame_timer: float = 0.0
var _current_frame: int = 0
var _is_playing: bool = false

func _ready() -> void:
	_update_parent_reference()
	
	if not Engine.is_editor_hint():
		if not autoplay.is_empty():
			play(autoplay)

func _process(delta: float) -> void:
	if not _is_playing: return
	if Engine.is_editor_hint() and not preview_in_editor: return
	if not parent or _active_anim == null: return

	# Use ABS() so the timer always counts up, regardless of direction
	_frame_timer += delta * abs(speed_scale)
	
	# Safety check for 0 FPS
	var anim_fps = _active_anim.fps if _active_anim.fps > 0 else 0.001
	var frame_duration = 1.0 / anim_fps
	
	while _frame_timer >= frame_duration:
		_frame_timer -= frame_duration
		_advance_frame()

func _advance_frame() -> void:
	if _active_anim == null: return
	
	var frame_limit = _active_anim.h_frames * _active_anim.v_frames
	if view_row_index != -1:
		frame_limit = _active_anim.h_frames
	
	# NEW: Determine direction based on speed_scale
	var direction = sign(speed_scale)
	if direction == 0: direction = 1 # Prevent getting stuck
	
	_current_frame += int(direction)
	
	# Handle Looping (Both Forward and Backward)
	if _current_frame >= frame_limit:
		if _active_anim.loop:
			_current_frame = 0
		else:
			_current_frame = frame_limit - 1
			_is_playing = false
			
	elif _current_frame < 0:
		if _active_anim.loop:
			_current_frame = frame_limit - 1
		else:
			_current_frame = 0
			_is_playing = false
	
	# Apply to Parent (Same as before)
	if parent:
		var final_frame_index = _current_frame
		if view_row_index != -1:
			var actual_row = view_row_index
			if direction_map.size() == 8:
				actual_row = direction_map[view_row_index]
			final_frame_index = (actual_row * _active_anim.h_frames) + _current_frame
			
		parent.frame = final_frame_index
	
	# Apply to Parent
	if parent:
		var final_frame_index = _current_frame
		
		if view_row_index != -1:
			# REMAPPING MAGIC HAPPENS HERE
			# We use the view_row_index (0-7 standard) to look up the ACTUAL row from the array
			var actual_row = view_row_index
			
			# Safety check: if the map has 8 entries, use it. Otherwise fallback to default.
			if direction_map.size() == 8:
				actual_row = direction_map[view_row_index]
			
			var row_offset = actual_row * _active_anim.h_frames
			final_frame_index = row_offset + _current_frame
			
		parent.frame = final_frame_index

func play(anim_name: String) -> void:
	_update_parent_reference()

	# Don't restart if it's already playing the same looping animation
	if current_animation == anim_name and _is_playing and _active_anim and _active_anim.loop:
		return

	var found_anim: JuiceAnimation = null
	for anim in animations:
		if anim and anim.animation_name == anim_name:
			found_anim = anim
			break
			
	if found_anim == null:
		if not anim_name.is_empty():
			push_warning("JuiceAnimator: Animation '%s' not found on %s." % [anim_name, owner.name if owner else self.name])
		return
	
	_active_anim = found_anim
	current_animation = anim_name
	_current_frame = 0
	_frame_timer = 0.0
	_is_playing = true
	
	_apply_animation_to_parent()

func _apply_animation_to_parent() -> void:
	if parent and _active_anim:
		# Only update texture if it's different to prevent unnecessary redraws
		if parent.texture != _active_anim.texture:
			parent.texture = _active_anim.texture
		
		parent.hframes = _active_anim.h_frames
		parent.vframes = _active_anim.v_frames
		parent.frame = 0

func _update_parent_reference() -> void:
	if get_parent() is Sprite2D:
		parent = get_parent()
	else:
		parent = null

func stop() -> void:
	_is_playing = false

func is_playing_one_shot() -> bool:
	return _is_playing and _active_anim != null and not _active_anim.loop
