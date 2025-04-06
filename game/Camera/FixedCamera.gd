extends Area2D

@onready var fixedp_cam: PhantomCamera2D = $".."
const CAMERA_SHAKE : PhantomCameraNoise2D = preload("res://Camera/CameraShake.tres")

func _ready() -> void:
	Events.connect("combat_camera_shake", shake_camera)
	Events.connect("freeze_frame", freeze_frame)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("player entered")
		fixedp_cam.priority = 1


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("player exited")
		fixedp_cam.priority = 0


func shake_camera() -> void:
	fixedp_cam.set_noise(CAMERA_SHAKE)
	await get_tree().create_timer(0.15).timeout  # Wait for 0.3 seconds
	fixedp_cam.set_noise(null)
	pass

func freeze_frame(duration: float, slow_motion_scale: float = 0.0) -> void:
	#Engine.time_scale = slow_motion_scale
	#await get_tree().create_timer(duration, false).timeout  # Run timer in unscaled time
	#Engine.time_scale = 1.0  # Restore normal speed
	Engine.time_scale = slow_motion_scale
	await(get_tree().create_timer(duration, true, false, true).timeout)
	Engine.time_scale = 1
