extends Node2D

## Demo script for JuiceBox Pro "Before vs After" playground.
## This manages the UI state and triggers effects on the character.

@onready var character: CharacterBody2D = $CharacterBody2D
@onready var juice_camera: JuiceCamera2D = $JuiceCamera2D
@onready var impact_frame: ImpactFrame = $ImpactFrame
@onready var squash_stretch: SquashStretch = $CharacterBody2D/Sprite2D/SquashStretch
@onready var pop_label: PopLabelManager = $PopLabelManager
@onready var ghost_trail: GhostTrail = $CharacterBody2D/Sprite2D/GhostTrail

var juice_enabled: bool = false

func _ready() -> void:
	# Update UI initial state
	$UI/UI_Box/StatusLabel.text = "JUICE: DISABLED"
	$UI/UI_Box/StatusLabel.modulate = Color.RED
	
	# Connect character signals for reactive juicing
	character.jumped.connect(_on_character_jumped)
	character.landed.connect(_on_character_landed)

func _process(_delta: float) -> void:
	# Toggle trail based on velocity if enabled
	if juice_enabled:
		ghost_trail.active = abs(character.velocity.x) > 100.0 or not character.is_on_floor()
	else:
		ghost_trail.active = false

func _on_character_jumped() -> void:
	if juice_enabled:
		squash_stretch.trigger_jump()
		pop_label.spawn_text("JUMP!!", character.global_position, Color.SKY_BLUE)

func _on_character_landed() -> void:
	if juice_enabled:
		squash_stretch.trigger_land()
		juice_camera.add_trauma(2)

func _on_juice_toggle_pressed() -> void:
	juice_enabled = !juice_enabled
	$UI/UI_Box/StatusLabel.text = "JUICE: ENABLED" if juice_enabled else "JUICE: DISABLED"
	$UI/UI_Box/StatusLabel.modulate = Color.GREEN if juice_enabled else Color.RED
	
	# Reset state when disabling
	if not juice_enabled:
		ghost_trail.active = false

func _on_attack_button_pressed() -> void:
	# Simulate a hit
	if juice_enabled:
		juice_camera.add_trauma(5)
		impact_frame.play()
		pop_label.spawn_text("HIT!", character.global_position + Vector2(0, -50), Color.ORANGE_RED)
