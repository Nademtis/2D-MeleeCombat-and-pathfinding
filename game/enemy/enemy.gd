extends CharacterBody2D
class_name Enemy

@onready var bt_player: BTPlayer = $BTPlayer
var blackboard: Blackboard

@export var speed: float = 70
@export var hp: float = 5
var should_walk = false
@export var should_chase_debug = true

# Knockback variables
@export var knockback_duration: float = 0.05
@export var knockback_strength = 150

var knockback_force: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $animatedSprite2D

func _ready() -> void:
	@warning_ignore("narrowing_conversion")
	speed = randi_range(speed - 10, speed + 10)
	
	blackboard = bt_player.blackboard
	blackboard.set_var("chase_speed", speed)  # Store enemy speed in the blackboard
	blackboard.set_var("safe_velocity", Vector2.ZERO)  # Ensure safe_velocity always exists
	blackboard.set_var("is_knocked_back", false)
	
func take_damage():
	#print("enemy hit")
	set_velocity(Vector2.ZERO)
	
	# Apply knockback away from the player
	var direction = (global_position - PlayerStats.player_position).normalized()
	
	knockback_force = direction * knockback_strength
	knockback_timer = knockback_duration
	
	animation_player.play("enemy_hit")
	hp -= 1
	if hp <= 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	move_and_slide()
	#pass
	#if should_chase_debug:
	#	movement(_delta)

# Only chase after some timeout
func _on_start_nav_timeout() -> void:
	should_walk = true
	#navigation_agent_2d.target_position = PlayerStats.player_position

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
