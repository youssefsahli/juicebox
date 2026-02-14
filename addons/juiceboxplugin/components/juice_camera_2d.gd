@tool
class_name JuiceCamera2D
extends Camera2D

@export_group("Editor Tools")
## Drop a ShakeProfile here and click 'Test' to preview that specific feel.
@export var test_profile: ShakeProfile
@export var trigger_test: bool = false:
	set(value):
		if value:
			if test_profile:
				apply_profile(test_profile)
			else:
				add_trauma(0.5)
		trigger_test = false 

@export_group("Default Shake Settings")
@export var max_offset: Vector2 = Vector2(8, 6)
@export var max_roll: float = 0.5
@export var trauma_decay: float = 2.0

@export_group("Noise Settings")
@export var noise_frequency: float = 0.2
@export var noise_speed: float = 8.0
@export var stress_scalar: float = 1.0 

var trauma: float = 0.0
var noise: FastNoiseLite = FastNoiseLite.new()
var time: float = 0.0

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = noise_frequency
	noise.noise_type = FastNoiseLite.TYPE_PERLIN 

func _process(delta: float) -> void:
	if trauma > 0:
		var current_speed = noise_speed + (trauma * stress_scalar * 10.0)
		time += delta * current_speed
		trauma = max(trauma - trauma_decay * delta, 0)
		_apply_shake()
	elif offset != Vector2.ZERO or rotation != 0:
		_reset_camera(delta)

## API Maintained
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

## API Maintained/Extended
func shake(intensity: float, decay_override: float = -1.0) -> void:
	if decay_override > 0:
		trauma_decay = decay_override
	add_trauma(intensity)

## NEW: Apply a predefined profile resource
func apply_profile(profile: ShakeProfile) -> void:
	trauma_decay = profile.decay
	noise_speed = profile.speed
	stress_scalar = profile.stress
	add_trauma(profile.intensity)

func _apply_shake() -> void:
	var shake_amount = pow(trauma, 3) 
	rotation = deg_to_rad(max_roll * shake_amount * noise.get_noise_1d(time))
	offset.x = max_offset.x * shake_amount * noise.get_noise_1d(time + 100)
	offset.y = max_offset.y * shake_amount * noise.get_noise_1d(time + 200)

func _reset_camera(delta: float) -> void:
	offset = offset.lerp(Vector2.ZERO, delta * 10.0)
	rotation = lerp(rotation, 0.0, delta * 10.0)
