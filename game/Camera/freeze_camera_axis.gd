extends Area2D

@export var freeze_axis : Enums.AXIS

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Events.emit_signal("camera_freeze_axis", freeze_axis)
		#signal up to parent node to freeze freeze_axis


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		Events.emit_signal("camera_stop_freeze_axis")
		#signal up to parent node to freeze freeze_axis
