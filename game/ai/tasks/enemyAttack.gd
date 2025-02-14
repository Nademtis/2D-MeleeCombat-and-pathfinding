extends BTAction

@export var attack_animation_name : String
@export var attack_charge_animation_name : String

func _tick(delta: float) -> Status:
	agent.velocity = Vector2.ZERO
	var anim : AnimatedSprite2D = agent.animated_sprite_2d
	anim.play("attack_right")
	
	return SUCCESS
