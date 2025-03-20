extends Node2D
#breakable



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		#particles should spawn
		queue_free()
		pass
	
	if area.is_in_group("enemy_attack"):
		#particles should spawn
		queue_free()
		pass
