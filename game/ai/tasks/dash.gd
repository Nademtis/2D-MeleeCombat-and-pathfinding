extends BTAction

@export var total_dash_time: float = 0.09  # Time the enemy dashes
@export var dash_speed: float = 350.0  # Speed of the dash
@export var towards_player: bool = false

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_has_been_setup: bool = false

func _tick(delta: float) -> Status:
	if not dash_has_been_setup:
		setup_dash()
		
	dash_timer -= delta
	var current_speed = lerp(dash_speed, 0.0, 1.0 - (dash_timer / total_dash_time))
	agent.velocity = dash_direction * current_speed
	
	if dash_timer >= 0:
		return RUNNING
	
	dash_has_been_setup = false
	return SUCCESS

func setup_dash() -> void:
	var player_position = PlayerStats.player_position
	dash_direction = (player_position - agent.global_position).normalized()
	
	# Reverse direction if dashing away from player
	if not towards_player:
		dash_direction *= -1
	
	dash_timer = total_dash_time
	dash_has_been_setup = true  # Prevent multiple setups
