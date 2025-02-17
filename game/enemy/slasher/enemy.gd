extends CharacterBody2D
class_name Enemy

@onready var bt_player: BTPlayer = $BTPlayer
var blackboard: Blackboard

@export var speed: float = 70
@export var hp: float = 5
@export var poise: float = 3
var should_chase = false
@export var should_chase_debug = true
@export var attack_range_px = 30

# Knockback variables
@export var knockback_duration: float = 0.05
@export var knockback_strength = 150

var knockback_force: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $animatedSprite2D
@onready var stunned_birds: AnimatedSprite2D = $stunnedBirds

@onready var hit_stun_timer: Timer = $hitStunTimer #when enemy is hit, trigger the timer
@onready var can_be_stunned_again_timer: Timer = $canBeStunnedAgainTimer

const DEAD_SLASHER = preload("res://enemy/slasher/dead_slasher.tscn")
@onready var health_bar: HealthBar= $healthBar
@onready var poise_bar: PoiseBar= $PoiseBar


func _ready() -> void:
	@warning_ignore("narrowing_conversion")
	speed = randi_range(speed - 10, speed + 10)
	
	blackboard = bt_player.blackboard
	blackboard.set_var("chase_speed", speed)  # Store enemy speed in the blackboard
	blackboard.set_var("safe_velocity", Vector2.ZERO)  # Ensure safe_velocity always exists
	#blackboard.set_var("is_knocked_back", false)
	
	health_bar.init_health(hp)
	poise_bar.init_health(poise)
	
	if animated_sprite_2d.material is ShaderMaterial:
		animated_sprite_2d.material = animated_sprite_2d.material.duplicate()
	
func take_damage():
	set_velocity(Vector2.ZERO)
	
	#bt_player.active = false
	if hit_stun_timer.is_stopped() && can_be_stunned_again_timer.is_stopped():
		stunned_birds.visible = true
		animated_sprite_2d.play("idle")
		hit_stun_timer.start()
		
	# setup knockback away from the player
	var direction = (global_position - PlayerStats.player_position).normalized()
	knockback_force = direction * knockback_strength
	knockback_timer = knockback_duration
	
	# Flash white using the shader
	#animated_sprite_2d.play("idle")
	var mat = animated_sprite_2d.material  # Change to match your enemy's sprite node
	if mat is ShaderMaterial:
		mat.set_shader_parameter("flash_amount", 1.0)  # Full white
		await get_tree().create_timer(0.1).timeout  # Flash duration
		mat.set_shader_parameter("flash_amount", 0.0)  # Reset
	
	animation_player.play("enemy_hit")
	hp -= 1
	health_bar._set_health(hp)
	if hp <= 0:
		var corpse = DEAD_SLASHER.instantiate()
		corpse.global_position = global_position
		get_tree().root.add_child(corpse)
		queue_free()

func _physics_process(_delta: float) -> void:
	#print(hit_stun_timer.time_left > 0)
	if knockback_timer > 0:
		velocity = knockback_force
		knockback_timer -= _delta
		
		# Gradually reduce knockback force (smooth stop)
		knockback_force = knockback_force.lerp(Vector2.ZERO, _delta * 22)
	
	move_and_slide()

# Used for avoidance
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	#var delta = 1.0 / Engine.physics_ticks_per_second
	#velocity = velocity.lerp(safe_velocity, 5 * delta)
	blackboard.set_var("safe_velocity", safe_velocity)
	#move_and_slide()
	

#func movement(delta: float) -> void:
	## Apply knockback first if active
	#if knockback_timer > 0:
		#velocity = knockback_force
		#
		## Reduce knockback over time (linear decay)
		#knockback_timer -= delta
		#knockback_force = knockback_force.lerp(Vector2.ZERO, delta * 2)  # Smooth decay
		#return  # Skip normal movement during knockback
#
	## Normal movement logic
	#if not should_walk:
		#return
	#
	#navigation_agent_2d.target_position = PlayerStats.player_position
	#var direction = (navigation_agent_2d.get_next_path_position() - global_position).normalized()
	#
	#var intended_velocity = direction * speed
	#navigation_agent_2d.velocity = intended_velocity

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		take_damage()

func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		should_chase = true

func _on_hit_stun_timer_timeout() -> void:
	#bt_player.active = true
	stunned_birds.visible = false
	can_be_stunned_again_timer.start()
	pass # Replace with function body.

func is_stunned() -> bool:
	#print("is stunned was called")
	return hit_stun_timer.time_left > 0

func recently_hit() -> bool:
	return hit_stun_timer.time_left > 0 or can_be_stunned_again_timer.time_left > 0
