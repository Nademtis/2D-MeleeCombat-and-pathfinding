extends Node

@export var hp : float = 10




func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		hp -= 1
		print("player was hit")
