@tool
class_name JuiceAudio
extends AudioStreamPlayer2D

## Auto-randomizes pitch and volume to prevent "robotic" repetition.

@export_group("Variation")
## Random pitch variance. 0.1 means pitch can vary by ±0.1.
@export_range(0.0, 2.0) var pitch_randomness: float = 0.1
## Random volume variance in dB.
@export_range(0.0, 10.0) var volume_randomness_db: float = 2.0

@export_group("Editor")
@export var test_sound: bool = false:
	set(value):
		if value: play_varied()
		test_sound = false

# Cache original values so we don't drift over time
@onready var _base_pitch: float = pitch_scale
@onready var _base_volume: float = volume_db

func play_varied(from_position: float = 0.0) -> void:
	# Apply Randomness
	pitch_scale = _base_pitch + randf_range(-pitch_randomness, pitch_randomness)
	volume_db = _base_volume + randf_range(-volume_randomness_db, volume_randomness_db)
	
	play(from_position)

# Helper to play standard sound without variation
func play_standard() -> void:
	pitch_scale = _base_pitch
	volume_db = _base_volume
	play()
