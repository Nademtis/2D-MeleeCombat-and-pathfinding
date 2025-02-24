extends Node2D
class_name EnemyAttack

@onready var animation_player: AnimationPlayer = $"newAttack/AnimationPlayer"
@onready var animated_sprite_2d: AnimatedSprite2D = $"newAttack/AnimatedSprite2D"

@onready var collision_shape_2d: CollisionPolygon2D = $Area2D/CollisionShape2D


func _ready() -> void:
	animated_sprite_2d.play("attack3")
	#animation_player.play("coll")
	pass



func _on_kill_timer_timeout() -> void:
	queue_free()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()


func _on_animated_sprite_2d_frame_changed() -> void:
	if not animated_sprite_2d: # null check
		return
	
	if animated_sprite_2d.animation == "attack3" and animated_sprite_2d.frame == 5:
		collision_shape_2d.disabled = false
	else:
		collision_shape_2d.disabled = true
		
