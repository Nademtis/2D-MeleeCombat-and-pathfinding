extends Sprite2D

@export var rotation_speed: float = 12.0  # Adjust rotation speed

func _process(delta: float) -> void:
	var direction = (PlayerStats.player_position - global_position).normalized()
	var target_angle = direction.angle()

	# Offset correction if the arrow points up by default
	target_angle += deg_to_rad(-90)  # Adjust this if needed

	# Smoothly rotate towards the target angle
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
