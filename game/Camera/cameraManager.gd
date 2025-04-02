extends Node
class_name CameraManager

@onready var follow_pcam: PhantomCamera2D = $FollowPcam
@onready var player_zoomed_camera: PhantomCamera2D = $PlayerZoomedCamera

var look_ahead : bool = true
@onready var change_look_ahead_timer: Timer = $changeLookAheadTimer

var look_ahead_direction : Vector2
var last_input_vector: Vector2 = Vector2.ZERO  # Stores last movement direction

@export var follow_offset_strength : float = 15
@export var y_multiplier: float = 1.5  # Increase Y offset strength

@onready var phantom_camera_host: PhantomCameraHost = $Camera2D/PhantomCameraHost


func _ready() -> void:
	Events.connect("camera_freeze_axis", freeze_axis)
	Events.connect("camera_stop_freeze_axis", stop_freeze_axis)
	start_level_camera() #starts zoomed in on player

func _process(delta: float) -> void:
	#print(phantom_camera_host._active_pcam_2d.name)
	#print(PlayerStats.player_position)
	print
	if look_ahead:
		camera_lookahead()
		
	#logic below is for managing camera look ahead
	var current_input_vector : Vector2 = PlayerStats.player_input_vector
	if last_input_vector != current_input_vector and current_input_vector != Vector2.ZERO:
		last_input_vector = current_input_vector
		change_look_ahead_timer.start()

func start_level_camera() -> void:
	#if spawning at checkpoint in same level set start cameras to correct position
	var active_checkpoint : Checkpoint = CheckpointManager.get_active_checkpoint()
	
	follow_pcam.set_follow_damping(false)
	
	#start at zoomed in
	follow_pcam.priority = 0
	player_zoomed_camera.priority = 1
	
	#then go to follow pcam
	await get_tree().create_timer(1).timeout
	follow_pcam.set_follow_damping(true)
	player_zoomed_camera.priority = 0
	follow_pcam.priority = 1
	

func camera_lookahead() -> void:
	var target_offset : Vector2 = look_ahead_direction * follow_offset_strength
	target_offset.y *= y_multiplier #add to y, since screen format - player need to look further down
	var current_offset = follow_pcam.get_follow_offset()  # Get current camera offset
	var smooth_offset = current_offset.lerp(target_offset, 0.025)  # Lerp with a smoothing factor
	follow_pcam.set_follow_offset(smooth_offset)

func freeze_axis (axis: Enums.AXIS) -> void:
	if axis == Enums.AXIS.Xaxis:
		follow_pcam.set_lock_axis(1)
	if axis == Enums.AXIS.Yaxis:
		follow_pcam.set_lock_axis(2)

func stop_freeze_axis () -> void:
	#print("stop freeze axis")
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
	# only change look ahead direction if same input is held for some time
	if last_input_vector == PlayerStats.player_input_vector:
		look_ahead_direction = last_input_vector
