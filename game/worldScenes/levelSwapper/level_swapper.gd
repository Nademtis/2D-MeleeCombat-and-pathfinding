extends Area2D
class_name LevelSwapper

@export var next_level_url : PackedScene
@export var target_spawn_id : String

func _ready():
	#print("Next level URL: ", next_level_url)
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#print("should swap level")
		Events.emit_signal("fade_to_black", 1)
		Events.emit_signal("immobilize_player")
		#var new_level : Level = Level.new(next_level_url, level_name)
		await get_tree().create_timer(1.5).timeout
		
		#LevelManager.load_level(new_level)
		print("from levelSwapper " , next_level_url) # this is null even when i added level to exported var
		LevelManager.load_level(next_level_url, target_spawn_id)
