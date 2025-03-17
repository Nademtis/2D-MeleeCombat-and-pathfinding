extends Node
var follow_player : bool = true

@export var follow_offset_strength : float = 15
@export var y_multiplier: float = 1.8  # Increase Y offset strength

@onready var follow_pcam: PhantomCamera2D = $FollowPcam

func _process(delta: float) -> void:
	#refactor to using input vector PlayerStatsplayer_input_vector
	var target_offset : Vector2
	if follow_player and PlayerStats.player_input_vector != Vector2.ZERO:
		# Normalize velocity to maintain consistent lookahead distance
		target_offset = PlayerStats.player_input_vector * follow_offset_strength
		
		#add to y
		target_offset.y *= y_multiplier
		
		follow_pcam.set_follow_offset(target_offset)
	else:
		# Reset lookahead when player stops moving
		follow_pcam.set_follow_offset(Vector2.ZERO)
		
		
	print(target_offset)  # Debugging
	
