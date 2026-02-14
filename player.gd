extends CharacterBody2D

@export_group("Movement Stats")
@export var speed: float = 400.0
@export var acceleration: float = 2500.0 # New: How fast we reach max speed
@export var friction: float = 15.0     # New: Higher value for tighter stops
@export var dash_speed: float = 1200.0

# References
@onready var squash: SquashStretch = $Sprite2D/SquashStretch 
@onready var anim: JuiceAnimator = $Sprite2D/JuiceAnimator
@onready var sprite: Sprite2D = $Sprite2D
@onready var ghost_trail: GhostTrail = $Sprite2D/GhostTrail

# Safe Camera Access
var camera: Camera2D:
	get: return get_viewport().get_camera_2d()

# State
var is_dashing: bool = false
var mouse_angle: float = 0.0

func _physics_process(delta: float) -> void:
	# 1. Update Visual Orientation
	var mouse_pos = get_global_mouse_position()
	mouse_angle = global_position.angle_to_point(mouse_pos)
	_update_animator_direction(mouse_angle)
	
	# 2. Gather Input
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# --- DASH CHECK ---
	if Input.is_action_just_pressed("dash") and not is_dashing:
		# Improvement: If no input, dash towards mouse. If input, dash in movement dir.
		var dash_dir = move_dir
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT.rotated(mouse_angle)
			
		start_dash(dash_dir)
	
	# --- MOVEMENT PHYSICS ---
	if is_dashing:
		# Dash Friction (Linear drag feels better for dashes than Lerp)
		velocity = velocity.move_toward(Vector2.ZERO, 3000.0 * delta)
		anim.play("dash")
		
		# End dash condition
		if velocity.length() < speed:
			is_dashing = false
			ghost_trail.active = false
	else:
		if move_dir != Vector2.ZERO:
			# ACCELERATION: move_toward gives weight, preventing "robotic" snaps
			velocity = velocity.move_toward(move_dir * speed, acceleration * delta)
			
			anim.play("run")
			_handle_moonwalk_animation(move_dir)
		else:
			# FRICTION: Lerp gives a nice "slide to stop" feeling
			velocity = velocity.lerp(Vector2.ZERO, friction * delta)
			
			# Snap to 0 if very slow to prevent micro-sliding
			if velocity.length_squared() < 100:
				velocity = Vector2.ZERO
				
			anim.play("idle")
			anim.speed_scale = 1.0

	move_and_slide()

	# --- SHOOTING ---
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _handle_moonwalk_animation(move_dir: Vector2) -> void:
	# Calculate aim direction
	var look_dir = Vector2.RIGHT.rotated(mouse_angle)
	
	# Dot Product: 1.0 (Same), 0.0 (Perpendicular), -1.0 (Opposite)
	var relation = look_dir.dot(move_dir)
	
	# HYSTERESIS:
	# We use a "buffer zone" so the animation doesn't flicker when strafing sideways.
	# If we are already running backward, we stay backward until we clearly move forward.
	var is_moving_back = anim.speed_scale < 0
	
	if is_moving_back:
		# Switch to Forward only if we are clearly moving forward (> 0.1)
		if relation > 0.1:
			anim.speed_scale = 1.0
	else:
		# Switch to Backward only if we are clearly moving backward (< -0.1)
		if relation < -0.1:
			anim.speed_scale = -1.0

func _update_animator_direction(angle: float) -> void:
	var normalized_angle = fmod(angle, TAU)
	if normalized_angle < 0: normalized_angle += TAU
	var octant = int((normalized_angle + (TAU / 16.0)) / (TAU / 8.0)) % 8
	if anim.view_row_index != octant:
		anim.view_row_index = octant

func start_dash(dir: Vector2) -> void:
	is_dashing = true
	velocity = dir * dash_speed
	ghost_trail.active = true
	
	# Align squash stretch with movement
	squash.rotation = dir.angle()
	squash.jump_scale = Vector2(1.5, 0.6)
	squash.trigger_jump()
	
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(0.2)

func shoot() -> void:
	var b = preload("res://bullet.tscn").instantiate()
	get_parent().add_child(b)
	var spawn_offset = Vector2.RIGHT.rotated(mouse_angle) * 40.0
	b.global_position = global_position + spawn_offset
	b.rotation = mouse_angle
	
	# Recoil
	squash.rotation = mouse_angle
	squash.jump_scale = Vector2(0.7, 1.4)
	squash.trigger_jump()
	
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(0.15)
