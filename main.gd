extends Node2D

@onready var camera = $JuiceCamera2D
@onready var player = $Player

func _ready() -> void:
	camera.zoom = Vector2(0.1, 0.1)
	var t = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	t.tween_property(camera, "zoom", Vector2(1, 1), 1.5)

func _on_enemy_spawn_timer_timeout() -> void:
	var e = preload("res://enemy.tscn").instantiate()
	var rect = get_viewport_rect()
	
	# Random edge spawn logic...
	var spawn_pos = Vector2.ZERO
	if randf() > 0.5:
		spawn_pos.x = randf_range(0, rect.size.x)
		spawn_pos.y = -50 if randf() > 0.5 else rect.size.y + 50
	else:
		spawn_pos.y = randf_range(0, rect.size.y)
		spawn_pos.x = -50 if randf() > 0.5 else rect.size.x + 50
		
	e.global_position = spawn_pos
	add_child(e)
