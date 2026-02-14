@tool
class_name PopLabelManager
extends Node2D

## Spawns floating labels (Combat Text).
## Use for damage numbers, "Level Up!", etc.

@export_group("Resources")
## Optional custom font for the labels.
@export var font_resource: Font

@export_group("Movement")
## Base direction and speed of movement.
@export var drift_velocity: Vector2 = Vector2(0, -100)
## Downward pull applied to the drift over time.
@export var gravity: float = 200.0

@export_group("Editor Tools")
@export var test_pop: bool = false:
	set(value):
		if value: spawn_text("Critical!", global_position)
		test_pop = false

## Spawns a floating label at the global position.
func spawn_text(text: String, pos: Vector2, color: Color = Color.WHITE) -> void:
	var label = Label.new()
	label.text = text
	label.top_level = true
	label.global_position = pos
	label.modulate = color
	
	if font_resource:
		label.add_theme_font_override("font", font_resource)
	
	get_tree().root.add_child(label)

	var tween = label.create_tween().set_parallel(true)
	var final_pos = pos + drift_velocity
	
	# Animate position with gravity effect
	tween.tween_property(label, "global_position:y", final_pos.y, 0.5).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "global_position:x", pos.x + randf_range(-20, 20), 0.5)
	
	# Fade and pop scale
	label.scale = Vector2.ZERO
	tween.tween_property(label, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.2)
	tween.chain().tween_callback(label.queue_free)
