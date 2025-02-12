extends BTAction
#chasePlayer


func _tick(delta: float) -> Status:
	# Get the enemy reference
	var enemy: Enemy = agent as Enemy
	if not enemy:
		return FAILURE

	enemy.navigation_agent_2d.target_position = PlayerStats.player_position

	# Get the next position along the path
	var direction = (enemy.navigation_agent_2d.get_next_path_position() - enemy.global_position).normalized()
	if direction == Vector2.ZERO:
		print("no path -> failure")
		return FAILURE  # No path available

	# Get chase speed from the blackboard
	var chase_speed = blackboard.get_var("chase_speed", enemy.speed, true)
	# Compute intended velocity
	var intended_velocity = direction * chase_speed
	# Apply avoidance (if available)
	var safe_velocity = blackboard.get_var("safe_velocity", Vector2.ZERO, true)
	
	if safe_velocity != Vector2.ZERO:
		enemy.velocity = enemy.velocity.lerp(safe_velocity, 10 * delta) # 5

	enemy.navigation_agent_2d.velocity = intended_velocity
	return RUNNING
