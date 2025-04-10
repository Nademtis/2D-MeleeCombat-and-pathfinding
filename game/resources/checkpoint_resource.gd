extends RefCounted
class_name Checkpoint

var level_name: String
var position: Vector2
var spawn_id: String

func _init(p_level_name: String, p_position: Vector2, p_spawn_id: String = "") -> void:
	level_name = p_level_name
	position = p_position
	spawn_id = p_spawn_id

func is_same_as(other: Checkpoint) -> bool:
	if other == null:
		return false
	return level_name == other.level_name and position.is_equal_approx(other.position)
