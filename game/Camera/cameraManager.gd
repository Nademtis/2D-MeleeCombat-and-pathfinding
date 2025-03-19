extends Node
class_name CameraManager

var look_ahead : bool = true
@onready var change_look_ahead_timer: Timer = $changeLookAheadTimer

var look_ahead_direction : Vector2
var last_input_vector: Vector2 = Vector2.ZERO  # Stores last movement direction

@export var follow_offset_strength : float = 15
@export var y_multiplier: float = 1.5  # Increase Y offset strength

@onready var follow_pcam: PhantomCamera2D = $FollowPcam
func _ready() -> void:
	Events.connect("camera_freeze_axis", freeze_axis)
	Events.connect("camera_stop_freeze_axis", stop_freeze_axis)

func _process(delta: float) -> void:
	if look_ahead:
		camera_lookahead()
		
		
	var current_input_vector : Vector2 = PlayerStats.player_input_vector
	if last_input_vector != current_input_vector and current_input_vector != Vector2.ZERO:
		last_input_vector = current_input_vector
		change_look_ahead_timer.start()
		print("timer started")
		
	
func camera_lookahead() -> void:
	var target_offset : Vector2 = look_ahead_direction * follow_offset_strength
	target_offset.y *= y_multiplier #add to y, since screen format
	
	var current_offset = follow_pcam.get_follow_offset()  # Get current camera offset
	var smooth_offset = current_offset.lerp(target_offset, 0.025)  # Lerp with a smoothing factor
	
	follow_pcam.set_follow_offset(smooth_offset)
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


func get_direction_from_side(side:Vector2) -> Enums.DIRECTION:
	var direction : Enums.DIRECTION
	match side:
		Vector2(1, 0): direction = Enums.DIRECTION.E
		Vector2(-1, 0): direction = Enums.DIRECTION.W
		Vector2(0, 1): direction = Enums.DIRECTION.S
		Vector2(0, -1): direction = Enums.DIRECTION.N
		Vector2(1, 1): direction = Enums.DIRECTION.NE
		Vector2(-1, 1): direction = Enums.DIRECTION.NW
		Vector2(1, -1): direction = Enums.DIRECTION.SE
		Vector2(-1, -1): direction = Enums.DIRECTION.SW
	#print(Enums.DIRECTION.keys()[direction])
	return direction


func _on_change_look_ahead_timer_timeout() -> void:
	if last_input_vector == PlayerStats.player_input_vector:
		print("should change")
		look_ahead_direction = last_input_vector
	else:
		print("should not change")
	
	#print("change from: ", Enums.DIRECTION.keys()[get_direction_from_side(look_ahead_direction)] )
	
	#print("change to: ", Enums.DIRECTION.keys()[get_direction_from_side(look_ahead_direction)] )
	
	pass # Replace with function body.
