extends RefCounted
class_name Level

var level_path: String
var level_name: String

func _init(p_level_path: String, p_level_name : String) -> void:
	level_path = p_level_path
	level_name = p_level_name
