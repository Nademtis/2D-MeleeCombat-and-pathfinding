extends RefCounted
class_name Level

var level_path: String
var level_name: String
var player_spawn_pos : Vector2

func _init(p_level_path: String, p_level_name : String, p_player_spawn_pos : Vector2) -> void:
	level_path = p_level_path
	level_name = p_level_name
	player_spawn_pos = p_player_spawn_pos
