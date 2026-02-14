@tool
class_name SquashStretch
extends Node2D

## Procedural deformation for Sprite-based entities.
## Targets the Parent node's scale.

@export_group("Scales")
## Scale target for vertical movement (e.g., jumping).
@export var jump_scale: Vector2 = Vector2(0.8, 1.2)
## Scale target for vertical impact (e.g., landing).
@export var land_scale: Vector2 = Vector2(1.3, 0.7)
## How quickly the parent returns to (1.0, 1.0).
@export var elasticity: float = 10.0

@export_group("Editor Tools")
@export var test_jump: bool = false:
	set(value): 
		if value: trigger_jump()
		test_jump = false

@export var test_land: bool = false:
	set(value):
		if value: trigger_land()
		test_land = false

@onready var parent: Node2D = get_parent()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint() or (Engine.is_editor_hint() and parent):
		parent.scale = parent.scale.lerp(Vector2.ONE, elasticity * delta)

## Deforms the parent into the "Jump" profile.
func trigger_jump() -> void:
	parent.scale = jump_scale

## Deforms the parent into the "Land" profile.
func trigger_land() -> void:
	parent.scale = land_scale
