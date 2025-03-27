extends BTAction

const SHOOTER_ARROW = preload("res://enemy/shooter/shooter_arrow.tscn")


var total_attack_charge_time : float = 0

var charging: bool = false
var charge_timer: float = 0.0
var attack_direction_is_locked : bool = false
var attack_direction : Vector2 


func _enter() -> void:
	total_attack_charge_time = agent.ranged_attack_charge_time

func _tick(delta: float) -> Status:
	blackboard.set_var("is_charging_attack", true)
	
	if agent.is_stunned():
		blackboard.set_var("is_Attacking", false)
		charging = false  # Interrupt charging when stunned
		#dashing = false   # Interrupt dashing when stunned
		agent.velocity = Vector2.ZERO  # Stop movement while stunned
		return FAILURE  # Return failure to halt other actions
	
	if not charging:
		charging = true
		charge_timer = total_attack_charge_time
		agent.bow_animated_sprite_2d.play("attack")
		attack_anim()
	
	else: #handle attack
		charge_timer -= delta
		flip_anim_to_point_at_player()
		
		if not attack_direction_is_locked:
			attack_direction = (PlayerStats.player_position - agent.global_position).normalized()
			
			if charge_timer <= total_attack_charge_time * 0.20: # Lock direction when charge_timer reaches 20% left
				attack_direction_is_locked = true
		
		if charge_timer <= 0:
			charging = false
			attack_direction_is_locked = false
			attack()
			return SUCCESS
			
	return RUNNING

func attack_anim() -> void:
	agent.animated_sprite_2d.play("attack_right")

func flip_anim_to_point_at_player() -> void:
	if agent.global_position.x > PlayerStats.player_position.x:
		agent.animated_sprite_2d.flip_h = true
	else:
		agent.animated_sprite_2d.flip_h = false

func attack() -> void:
	blackboard.set_var("is_charging_attack", false)
	var arrow_instance : Projectile = SHOOTER_ARROW.instantiate()
	arrow_instance.setup_projectile(1, 125, attack_direction)
	agent.add_child(arrow_instance)
