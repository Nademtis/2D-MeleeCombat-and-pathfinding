extends BTAction

#@export var attack_animation_name : String
#@export var attack_charge_animation_name : String
@export var attack_charge_time : float = 0.3
const ATTACK = preload("res://assets/enemy/enemyAttack.tscn")

var charging : bool = false
var charge_timer: float = 0.0  # Tracks time left until attack

func _tick(delta: float) -> Status:
	agent.velocity = Vector2.ZERO
	var anim: AnimatedSprite2D = agent.animated_sprite_2d
	
	if not charging:
		# Start charging
		charging = true
		charge_timer = attack_charge_time
		play_attack_anim()
	
	# Reduce charge time each frame
	if charging:
		charge_timer -= delta
		
		# If charge is complete, perform attack
		if charge_timer <= 0:
			charging = false  # Reset state for next attack
			
			# Get the player's position
			var player_position = PlayerStats.player_position
			var direction = (player_position - agent.global_position).normalized()
			
			# Instantiate the attack
			var attack_instance = ATTACK.instantiate()
			attack_instance.global_position = agent.global_position# + (direction * 5) # Adjust offset as needed
			attack_instance.rotation = direction.angle() + 90
			
			# Add to the scene
			agent.get_tree().current_scene.add_child(attack_instance)
			
			return SUCCESS  # Attack finished
	
	return RUNNING  # Still charging

func play_attack_anim() -> void:
	var anim: AnimatedSprite2D = agent.animated_sprite_2d
	var player_position = PlayerStats.player_position
	
	if player_position.x >= agent.global_position.x:
		anim.play("attack_right")  # Player is to the right
	else:
		anim.play("attack_left")   # Player is to the left
