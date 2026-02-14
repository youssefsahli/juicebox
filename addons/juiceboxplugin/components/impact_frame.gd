@tool
class_name ImpactFrame
extends Node

## Handles "Hitstop" (Time Freezing) and Screen Flashes.
## Note: Engine.time_scale is global. Only one impact should control it at a time.

@export_group("Freeze Settings")
@export var freeze_duration: float = 0.05
@export var time_scale_factor: float = 0.0

@export_group("Visual Flash")
@export var flash_screen: bool = false
@export var flash_color: Color = Color(1, 1, 1, 0.8) # Default slightly transparent

@export_group("Editor Tools")
@export var test_impact: bool = false:
	set(value):
		if value: 
			if Engine.is_editor_hint():
				print("Impact Previewed")
			play()
		test_impact = false

# Static variable shared by ALL ImpactFrame nodes to prevent scale-drift
static var _original_time_scale: float = 1.0
static var _is_frozen: bool = false

func play() -> void:
	if not is_inside_tree(): return

	if flash_screen:
		_create_flash()
	
	# Handle Time Scale safely
	if not _is_frozen:
		_original_time_scale = Engine.time_scale
		_is_frozen = true
	
	Engine.time_scale = time_scale_factor
	
	# Create timer that ignores time_scale
	var timer = get_tree().create_timer(freeze_duration, true, false, true)
	await timer.timeout
	
	# Only restore if another impact hasn't taken over
	_is_frozen = false
	Engine.time_scale = _original_time_scale

func _create_flash() -> void:
	# Use a CanvasLayer so it stays fixed on screen
	var canvas = CanvasLayer.new()
	# Set layer to 1 to appear above most gameplay, but maybe below HUD (usually Layer 100+)
	canvas.layer = 1 
	
	var rect = ColorRect.new()
	rect.color = flash_color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Adding to the current scene is safer than the root for cleanup
	var target_parent = get_tree().current_scene if get_tree().current_scene else get_tree().root
	target_parent.add_child(canvas)
	canvas.add_child(rect)
	
	var tween = canvas.create_tween()
	# Ensure the tween processes even when paused/frozen
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) 
	
	tween.tween_property(rect, "modulate:a", 0.0, freeze_duration)
	tween.tween_callback(canvas.queue_free)
