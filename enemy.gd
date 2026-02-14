extends Area2D

@export var hp: int = 2
@export var speed: float = 150.0
@onready var pop_label_manager: PopLabelManager = $PopLabelManager
@onready var impact_frame: ImpactFrame = $ImpactFrame

var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not is_instance_valid(player): return
	
	# Chase
	var dir = (player.global_position - global_position).normalized()
	global_position += dir * speed * delta
	look_at(player.global_position)

func take_damage() -> void:
	hp -= 1
	
	# JUICE: Flash White shader param or modulate
	modulate = Color(10, 10, 10) # Simple flash hack
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if hp <= 0:
		die()
	else:
		# JUICE: Small floating text
		pop_label_manager.spawn_text("HIT", global_position, Color.WHITE)

func die() -> void:
	# JUICE: Hitstop (Freeze frame)
	impact_frame.freeze(0.08) # 80ms freeze
	
	# JUICE: Big Trauma
	var cam = get_viewport().get_camera_2d()
	if cam: cam.add_trauma(0.4)
	
	# JUICE: Score Pop
	pop_label_manager.spawn_text("+100", global_position, Color.YELLOW)
	
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
		die() # Kamikaze
