extends Area2D
#levelSwapper

@export var next_level_url : String
@export var level_name : String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("should swap level")
		Events.emit_signal("fade_to_black", 1)
		Events.emit_signal("immobilize_player")
		var new_level : Level = Level.new(next_level_url, level_name)
		await get_tree().create_timer(1.5).timeout
		LevelManager.load_level(new_level)
