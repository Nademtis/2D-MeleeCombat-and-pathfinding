extends Area2D

@onready var fixedp_cam: PhantomCamera2D = $".."



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player entered")
		fixedp_cam.priority = 1


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player exited")
		fixedp_cam.priority = 0
