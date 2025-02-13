extends BTAction

func _tick(_delta: float) -> Status:
	var enemy: Enemy = agent as Enemy
	if not enemy:
		return FAILURE

	var anim : AnimatedSprite2D = enemy.animated_sprite_2d
	
	# Check if enemy is moving
	if enemy.velocity.length() > 5:
		if enemy.velocity.x < 0:
			anim.play("walk_left")
		elif enemy.velocity.x > 0:
			anim.play("walk_right")
	else:
		anim.play("idle")

	return SUCCESS
