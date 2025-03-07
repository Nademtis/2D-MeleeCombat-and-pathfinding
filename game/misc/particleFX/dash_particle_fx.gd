extends Node2D
class_name DashParticleEffect

var animation
var color
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func setup_particle_fx(direction: Vector2, opacity: float = 1):
	color = Color(1, 1, 1, opacity)
	
	var angle = direction.angle() # Get angle in radians

	if angle >= -PI * 0.125 and angle < PI * 0.125:
		animation = "W" # fixed
	elif angle >= PI * 0.125 and angle < PI * 0.375:
		animation = "NW" # fixed
	elif angle >= PI * 0.375 and angle < PI * 0.625:
		animation = "N"# fixed
	elif angle >= PI * 0.625 and angle < PI * 0.875:
		animation = "NE"# fixed
	elif angle >= -PI * 0.875 and angle < -PI * 0.625:
		animation = "SE"# fixed
	elif angle >= -PI * 0.625 and angle < -PI * 0.375:
		animation = "S"# fixed
	elif angle >= -PI * 0.375 and angle < -PI * 0.125:
		animation = "SW"# fixed
	else:
		animation = "E"

func _ready() -> void:
	animated_sprite_2d.self_modulate = color
	animated_sprite_2d.play(animation)

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free() #since effect is done
