extends RefCounted
class_name Checkpoint

var level_name: String
var position: Vector2

func _init(p_level_name: String, p_position: Vector2) -> void:
	level_name = p_level_name
	position = p_position
