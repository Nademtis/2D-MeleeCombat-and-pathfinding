extends BTAction

@export var anim_name = "idle"
@export var wait_time : float = 1

var started : bool = false
var current_time : float = 0

func _tick(delta: float) -> Status:
	if not started:
		started = true
		current_time = wait_time
	
	if current_time <= 0:
		started = false
		return SUCCESS
	else:
		current_time -= delta
		return RUNNING
	
#func fix_sprite_flip():
	#var anim: AnimatedSprite2D = agent.animated_sprite_2d
	#anim.play(anim_name)
	#if agent.global_position.x > PlayerStats.player_position.x:
		#anim.flip_h = true
	#else:
		#anim.flip_h = false
		
	
