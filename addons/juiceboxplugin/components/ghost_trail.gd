@tool
class_name GhostTrail
extends Node2D # Changed from Node to Node2D to enable _draw

@export_group("Emission")
@export var emit_interval: float = 0.05
@export var active: bool = false

@export_group("Visuals")
@export var fade_time: float = 0.4
@export var color_modulate: Color = Color(0.3, 0.6, 1.0, 0.6)

var _parent_sprite: Sprite2D
var _timer: float = 0.0
var _ghosts: Array = [] # Stores snapshots: {pos, tex, rect, frame, alpha, flip}

func _ready() -> void:
	if get_parent() is Sprite2D:
		_parent_sprite = get_parent()
	
	# This is the secret sauce: 
	# It makes this node stay at (0,0) in the world while the parent moves.
	top_level = true 

func _process(delta: float) -> void:
	# Update existing ghosts' alpha
	var i = _ghosts.size() - 1
	while i >= 0:
		_ghosts[i].alpha -= delta / fade_time
		if _ghosts[i].alpha <= 0:
			_ghosts.remove_at(i)
		i -= 1
	
	# Spawn new ghosts
	if active and _parent_sprite:
		_timer += delta
		if _timer >= emit_interval:
			_add_ghost_snapshot()
			_timer = 0.0
	
	# Queue a redraw every frame there are ghosts present
	if not _ghosts.is_empty() or active:
		queue_redraw()

func _add_ghost_snapshot() -> void:
	# Calculate the exact region of the spritesheet to draw
	var src_rect = _parent_sprite.get_rect()
	# Adjust for frames
	var h_step = _parent_sprite.texture.get_width() / _parent_sprite.hframes
	var v_step = _parent_sprite.texture.get_height() / _parent_sprite.vframes
	
	var column = _parent_sprite.frame % _parent_sprite.hframes
	var row = _parent_sprite.frame / _parent_sprite.hframes
	
	var region = Rect2(column * h_step, row * v_step, h_step, v_step)

	_ghosts.append({
		"texture": _parent_sprite.texture,
		"pos": _parent_sprite.global_position,
		"scale": _parent_sprite.global_scale,
		"rot": _parent_sprite.global_rotation,
		"flip_h": _parent_sprite.flip_h,
		"flip_v": _parent_sprite.flip_v,
		"region": region,
		"alpha": 1.0,
		"offset": _parent_sprite.offset if _parent_sprite.centered else Vector2.ZERO
	})

func _draw() -> void:
	for g in _ghosts:
		var final_color = color_modulate
		final_color.a *= g.alpha
		
		# 1. Determine the scale, incorporating flips
		var final_scale = g.scale
		if g.flip_h: final_scale.x *= -1
		if g.flip_v: final_scale.y *= -1
		
		# 2. Apply the full transform (Position, Rotation, Scale)
		# This handles everything in one go.
		draw_set_transform(g.pos, g.rot, final_scale)
		
		# 3. Calculate drawing rect
		var draw_size = g.region.size
		# If the sprite is centered, we offset the drawing by half its size
		var draw_pos = -draw_size / 2.0 if _parent_sprite.centered else Vector2.ZERO
		draw_pos += g.offset
		
		draw_texture_rect_region(
			g.texture, 
			Rect2(draw_pos, draw_size), 
			g.region, 
			final_color
		)
		
	# 4. Reset transform so other things don't draw weirdly
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
