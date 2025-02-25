extends Node
#global ParticleFx

const DASH_PARTICLE_FX = preload("res://misc/particleFX/dash_particle_fx.tscn")

func spawn_dash_effect(direction: Vector2, _global_pos, opacity: float = 1):
	var dash_effect = DASH_PARTICLE_FX.instantiate() # Adjust path
	dash_effect.global_position = _global_pos
	dash_effect.setup_particle_fx(direction, opacity)
	get_tree().current_scene.add_child(dash_effect)
