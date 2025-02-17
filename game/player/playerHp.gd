extends Node
class_name PlayerHP
@export var hp : float = 10


func _ready() -> void:
	pass

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		hp -= 1
		Events.emit_signal("player_hp_changed", hp)
		print("player was hit")
