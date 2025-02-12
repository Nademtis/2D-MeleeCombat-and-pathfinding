extends BTAction
#chasePlayer


func _tick(delta: float) -> Status:
	if agent.should_walk == false:
		return FAILURE
	
	# Get the enemy reference
	var enemy: Enemy = agent as Enemy
	if not enemy:
		return FAILURE
	
	## Handle knockback (interrupts movement)
	#if enemy.knockback_timer > 0:
		#enemy.velocity = enemy.knockback_force
		#enemy.knockback_timer -= delta
		#enemy.knockback_force = enemy.knockback_force.lerp(Vector2.ZERO, delta * 5)
		#if enemy.knockback_timer <= 0:
			#blackboard.set_var("is_knocked_back", false)  # Reset knockback state
		#return RUNNING

	# Update navigation target
	# Set the target position
	# Set the target position
	enemy.navigation_agent_2d.target_position = PlayerStats.player_position

	# Get the next position along the path
	var direction = (enemy.navigation_agent_2d.get_next_path_position() - enemy.global_position).normalized()
	if direction == Vector2.ZERO:
		print("no path -> failure")
		return FAILURE  # No path available

	# Get chase speed from the blackboard
	var chase_speed = blackboard.get_var("chase_speed", enemy.speed)

	# Compute intended velocity
	var intended_velocity = direction * chase_speed

	# Apply avoidance (if available)
	var safe_velocity = blackboard.get_var("safe_velocity", Vector2.ZERO)
	
	if safe_velocity != Vector2.ZERO:
		enemy.velocity = enemy.velocity.lerp(safe_velocity, 10 * delta) # 5

	enemy.navigation_agent_2d.velocity = intended_velocity
	return RUNNING
