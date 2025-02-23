extends Node2D


@onready var animation_player: AnimationPlayer = $"new attack/AnimationPlayer"
@onready var animated_sprite_2d: AnimatedSprite2D = $"new attack/AnimatedSprite2D"


#TODO not used currently


func _ready() -> void:
	pass



func _on_kill_timer_timeout() -> void:
	queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animated_sprite_2d.play("attack2")
	animation_player.play("coll")
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished() -> void:
	#whole attack done
	queue_free()
	
	pass # Replace with function body.
