@tool
extends Resource
class_name JuiceAnimation

## The identifier used to call this animation via JuiceAnimator.play()
@export var animation_name: String = "new_animation"
@export var texture: Texture2D

@export_group("Grid Layout")
## Total number of horizontal columns in the sprite sheet.
@export_range(1, 256) var h_frames: int = 1
## Total number of vertical rows in the sprite sheet.
@export_range(1, 256) var v_frames: int = 1

@export_group("Playback")
## Playback speed in frames per second.
@export_range(0.1, 120.0, 0.1) var fps: float = 10.0
## Should the animation repeat?
@export var loop: bool = true
