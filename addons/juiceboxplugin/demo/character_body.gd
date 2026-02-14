extends CharacterBody2D

signal jumped
signal landed

@export_group("Movement Settings")
@export var speed: float = 300.0
@export var jump_velocity: float = -600.0
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0

@onready var animator: JuiceAnimator = $Sprite2D/JuiceAnimator
@onready var sprite: Sprite2D = $Sprite2D

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_on_floor: bool = false
var is_jumping: bool = false

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement(delta)
	_update_animations()
	
	move_and_slide()
	_detect_landing()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Keep a tiny bit of downward force to keep is_on_floor() stable
		velocity.y = min(velocity.y, 10.0)

func _handle_movement(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		is_jumping = true
		jumped.emit()

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func _update_animations() -> void:
	if not animator:
		return

	if animator.is_playing_one_shot():
		return

	if is_on_floor():
		is_jumping = false
		if abs(velocity.x) > 10.0:
			animator.play("run")
		else:
			animator.play("idle")
	else:
		# Aerial states
		if velocity.y < 0:
			animator.play("jump")
		else:
			animator.play("fall")

func _detect_landing() -> void:
	if is_on_floor() and not was_on_floor:
		#animator.play("land") 
		landed.emit()
	was_on_floor = is_on_floor()
