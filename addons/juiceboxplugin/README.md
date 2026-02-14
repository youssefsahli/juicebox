1. Executive Summary

JuiceBox Pro is a "Plug-and-Play" addon for Godot 4.x that provides high-fidelity game feel (screenshake, hitstop, squash & stretch) via modular nodes.

2. Technical Architecture

Core Principles

Composition over Inheritance: All features must be standalone Node or Node2D types that can be added as children to any entity (Player, Enemy, UI).

Zero-Setup: Nodes must work with default settings immediately upon being added to the scene tree.

Signal-Driven: Effects are triggered via standard Godot signals (e.g., connect area_entered -> JuiceNode.play()).

GDScript Only: No C# or GDExtension to ensure maximum compatibility (Web exports, Mobile, etc.).

File Structure

addons/juicebox_pro/
├── plugin.cfg                 # Metadata
├── icons/                     # 16x16 SVGs for the Editor UI
│   ├── icon_camera.svg
│   ├── icon_squash.svg
│   └── ...
├── components/                # The 5 Core Scripts
│   ├── juice_camera.gd
│   ├── impact_frame.gd
│   ├── squash_stretch.gd
│   ├── ghost_trail.gd
│   └── pop_label.gd
└── demo/                      # Marketing Assets
	├── demo_scene.tscn        # "Before vs After" Playground
	└── assets/


3. Feature Specifications (The "Big 5")

A. JuiceCamera2D (The Noise Shaker)

Replaces standard Camera2D with a trauma-based shake system.

Logic: Uses FastNoiseLite to generate continuous, organic offsets based on a trauma value (0.0 to 1.0) that decays over time.

Properties (@export):

max_offset (Vector2): Maximum pixel displacement (Default: (30, 20)).

max_roll (float): Maximum rotation in degrees (Default: 5.0).

trauma_decay (float): How quickly shake stops (Default: 0.8).

noise_speed (float): Frequency of the noise texture (Default: 2.0).

Public API:

add_trauma(amount: float): Adds to current trauma (clamped at 1.0).

B. ImpactFrame (The Time Stopper)

Creates "Hitstop" (Freeze frames) and screen flashes.

Logic: Manipulates Engine.time_scale for a fraction of a second, then restores it.

Properties (@export):

freeze_duration (float): Duration in seconds (Default: 0.05).

time_scale (float): The slowdown factor (Default: 0.0 for full stop).

flash_screen (bool): If true, creates a temporary ColorRect overlay.

flash_color (Color): Default White.

Dependencies: Must use await get_tree().create_timer(duration, true, false, true).timeout to ensure the timer runs even when the game is paused.

C. SquashStretch (The Animator)

Procedural deformation for Sprites.

Logic: Manipulates the scale of the Parent Node.

Properties (@export):

jump_scale (Vector2): Target scale when jumping (e.g., (0.7, 1.3)).

land_scale (Vector2): Target scale when landing (e.g., (1.4, 0.6)).

elasticity (float): How fast it returns to (1, 1) (Lerp weight).

Triggers:

trigger_jump()

trigger_land()

Optional: Auto-detect CharacterBody2D state changes.

D. GhostTrail (The Speed Indicator)

Creates trailing after-images.

Logic: Spawns simple Sprite2D copies of the parent at fixed time intervals, then tweens their alpha to 0.

Properties (@export):

emit_interval (float): Time between ghosts (Default: 0.05).

fade_time (float): Life duration of a ghost (Default: 0.4).

color_modulate (Color): Tint for the ghosts (Default: Blue/Transparent).

match_rotation (bool): Whether to copy parent rotation.

E. PopLabelManager (Combat Text)

Spawns floating numbers.

Logic: Instantiates a pooled Label that moves up and fades out.

Properties (@export):

font_resource (Font): Custom font support.

drift_velocity (Vector2): Movement direction (Default: (0, -50)).

gravity (float): Downward force over time.

scale_curve (Curve): Controls size over lifetime (Pop big -> shrink).

4. User Experience (DX) Requirements

1. The "Test" Button

Every node must have a boolean export variable test_effect (or @export_tool_button in Godot 4.2+) that allows the user to trigger the effect inside the editor without running the game.

Why: Instant feedback sells the tool.

2. Tooltips

All exported variables must have explicit tooltips explaining their unit of measurement (Seconds? Pixels? Degrees?).

3. Custom Icons

Each script must define a specific icon using @icon("res://addons/juicebox_pro/icons/icon_name.svg").

Why: It makes the scene tree look professional and organized, justifying the price tag.

5. Development Roadmap (5-Day Sprint)

Day 1: Setup Git, plugin.cfg, and implement JuiceCamera2D (Hardest math).

Day 2: Implement ImpactFrame and SquashStretch.

Day 3: Implement GhostTrail and PopLabelManager.

Day 4: Create the Demo Scene. This is crucial. It needs a "Before/After" toggle switch UI.

Day 5: Documentation (README), Icon design, and itch.io page formatting (GIF recording).

6. Success Metrics (ROI)

MVP Scope: strict adherence to the 5 features above. No 3D support in v1.0.

Asset Quality: The code must be clean enough that a beginner can read it and learn from it.

Marketing Asset: A 15-second video showing a grey cube.

Phase 1: Cube jumps (Boring).

Phase 2: ENABLE JUICEBOX. Cube jumps with squash, particles, screen shake, and impact frames.
