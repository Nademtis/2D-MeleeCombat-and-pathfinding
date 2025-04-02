extends Node
class_name PlayerHP
@export var hp : float = 10


func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("k"):
		take_damage(1)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		take_damage(1)
	
func take_damage(damage_taken:float) -> void:
	hp -= damage_taken
	Events.emit_signal("player_hp_changed", hp)
	
	Events.emit_signal("player_hit")
	Events.emit_signal("freeze_frame", 1, 0.25)
	
	if hp <= 0:
		die()
	
func die() -> void:
	
	LevelManager.player_died()
