@tool
extends EditorPlugin

const COMPONENTS = {
	"JuiceCamera2D": ["Camera2D", "res://addons/juicebox_pro/components/juice_camera.gd", "res://addons/juicebox_pro/icons/icon_camera.png"],
	"ImpactFrame": ["Node", "res://addons/juicebox_pro/components/impact_frame.gd", "res://addons/juicebox_pro/icons/icon_impact.svg"],
	"SquashStretch": ["Node", "res://addons/juicebox_pro/components/squash_stretch.gd", "res://addons/juicebox_pro/icons/icon_squash.svg"],
	"GhostTrail": ["Node2D", "res://addons/juicebox_pro/components/ghost_trail.gd", "res://addons/juicebox_pro/icons/icon_ghost.svg"],
	"PopLabelManager": ["Node2D", "res://addons/juicebox_pro/components/pop_label.gd", "res://addons/juicebox_pro/icons/icon_label.svg"],
	"JuiceAnimator": ["Node", "res://addons/juiceboxplugin/components/juice_animator.gd", "/mnt/chromeos/MyFiles/Code/juicebox_2026-02-11_20-39-36/juice-box/addons/juiceboxplugin/icons/icon_animator.png"],
	"JuiceAudio": ["AudioStreamPlayer2D", "/mnt/chromeos/MyFiles/Code/hyper-terminal/addons/juiceboxplugin/components/juice_audio.gd"]
}

func _enter_tree() -> void:
	for node_name in COMPONENTS:
		var data = COMPONENTS[node_name]
		add_custom_type(
			node_name, 
			data[0], 
			load(data[1]), 
			load(data[2])
		)
	print("JuiceBox Pro: Plugin initialized successfully.")

func _exit_tree() -> void:
	for node_name in COMPONENTS:
		remove_custom_type(node_name)
	print("JuiceBox Pro: Plugin cleaned up.")

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass
