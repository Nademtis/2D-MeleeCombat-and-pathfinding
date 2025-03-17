extends Node
class_name CameraManager

var follow_player : bool = true

@export var follow_offset_strength : float = 15
@export var y_multiplier: float = 1.8  # Increase Y offset strength

@onready var follow_pcam: PhantomCamera2D = $FollowPcam

func _ready() -> void:
	Events.connect("camera_freeze_axis", freeze_axis)
	Events.connect("camera_stop_freeze_axis", stop_freeze_axis)

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
		
		
	#print(target_offset)  # Debugging
	
	
func freeze_axis (axis: Enums.AXIS) -> void:
	print("should freeze")
	if axis == Enums.AXIS.Xaxis:
		follow_pcam.set_lock_axis(1)
	if axis == Enums.AXIS.Yaxis:
		follow_pcam.set_lock_axis(2)

func stop_freeze_axis () -> void:
	print("stop freeze axis")
	follow_pcam.set_lock_axis(0)
