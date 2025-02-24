extends BTAction

#@export var attack_animation_name : String
#@export var attack_charge_animation_name : String
@export var attack_charge_time : float = 0.20
@export var dash_time: float = 0.15  # Time the enemy dashes
@export var dash_speed: float = 250.0  # Speed of the dash
const ATTACK = preload("res://enemy/slasher/enemyAttack.tscn")

var charging: bool = false
var charge_timer: float = 0.0
var dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var attack_direction_is_locked : bool = false

func _enter() -> void:
	agent.attack_charge_time = attack_charge_time

func _tick(delta: float) -> Status:
	blackboard.set_var("is_Attacking", true)
	if agent.is_stunned():
		blackboard.set_var("is_Attacking", false)
		charging = false  # Interrupt charging when stunned
		dashing = false   # Interrupt dashing when stunned
		agent.velocity = Vector2.ZERO  # Stop movement while stunned
		return FAILURE  # Return failure to halt other actions
	
	# Handle charging and dashing states
	if charging or dashing:
		# Lerp between dash speed and 0 to create the slow down effect
		var current_speed = lerp(dash_speed, 0.0, 1.0 - (dash_timer / dash_time))
		agent.velocity = dash_direction * current_speed if dashing else Vector2.ZERO
	
	# Start Charging phase
	if not charging and not dashing:
		charging = true
		charge_timer = attack_charge_time
		play_attack_anim()
		#use this position, so player can juke
	
	if charging:
		charge_timer -= delta  # Reduce charge timer
		
		# Update dash direction every tick until 25% charge time is left
		if not attack_direction_is_locked:
			dash_direction = (PlayerStats.player_position - agent.global_position).normalized()
			
			if charge_timer <= attack_charge_time * 0.20: # Lock direction when charge_timer reaches 25% left
				attack_direction_is_locked = true
		# Update attack indicator every tick
		agent.update_attack_indicator(dash_direction, charge_timer)
			
		if charge_timer <= 0:
			charging = false
			start_attack()
			return RUNNING  # Keep running while dashing
		return RUNNING  # Still charging
	
	# Dashing phase
	if dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false
			agent.velocity = Vector2.ZERO
			blackboard.set_var("is_Attacking", false) #attack is done
			return SUCCESS  # Attack complete
		return RUNNING  # Still dashing
	return SUCCESS
	

func play_attack_anim() -> void:
	var anim: AnimatedSprite2D = agent.animated_sprite_2d
	var player_position = PlayerStats.player_position
	var direction = (player_position - agent.global_position).normalized()
	
	if direction.x >= 0:
		anim.play("attack_right")  # Player is to the right
		
	else:
		anim.play("attack_left")   # Player is to the left
		

func start_attack() -> void:
	attack_direction_is_locked = false
	#var player_position = PlayerStats.player_position
	#dash_direction = (player_position - agent.global_position).normalized()
	
	# Instantiate the attack effect
	var attack_instance = ATTACK.instantiate()
	attack_instance.position = dash_direction * 3
	attack_instance.rotation = dash_direction.angle()
	
	#agent.get_tree().current_scene.add_child(attack_instance)
	agent.add_child(attack_instance)
	
	# Start dashing
	dashing = true
	dash_timer = dash_time
