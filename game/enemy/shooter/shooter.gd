extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $animatedSprite2D
@onready var bow_sprite_2d: Sprite2D = $bow/bowSprite2D

#test variables
@export var rotation_speed: float = 12.0  # Adjust rotation speed


func _process(delta: float) -> void:
	point_bow_towards_player(delta)
	bow_y_sort()
	
	if PlayerStats.player_position.x < global_position.x:
		animated_sprite_2d.play("attack_left")
	else:
		animated_sprite_2d.play("attack_right")
		



func point_bow_towards_player(delta: float)-> void:
	var direction = (PlayerStats.player_position - global_position).normalized()
	var target_angle = direction.angle()
	# Offset correction if the arrow points up by default
	target_angle += deg_to_rad(-90)  # Adjust this if needed
	# Smoothly rotate towards the target angle
	bow_sprite_2d.rotation = lerp_angle(bow_sprite_2d.rotation, target_angle, rotation_speed * delta)

func bow_y_sort() -> void:
	if PlayerStats.player_position.y > global_position.y:
		bow_sprite_2d.z_index = 1
	else:
		bow_sprite_2d.z_index = 0
		
