extends RefCounted
class_name Checkpoint

var level_name: String
var position: Vector2

func _init(p_level_name: String, p_position: Vector2) -> void:
	level_name = p_level_name
	position = p_position

func is_same_as(other: Checkpoint) -> bool:
	if other == null:
		return false
	return level_name == other.level_name and position.is_equal_approx(other.position)
