extends CharacterBody2D
class_name Enemy

@onready var bt_player: BTPlayer = $BTPlayer
var blackboard: Blackboard

@export var speed: float = 70
@export var hp: float = 5
@export var max_poise: float = 30
@export var regain_poise_amount : float = 0.5
var current_poise = max_poise
@onready var regain_poise_timer: Timer = $regainPoiseTimer
@onready var recently_hit_timer: Timer = $recentlyHitTimer


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

#ui indicator stuff
@onready var enemy_direction_indicator: Sprite2D = $walkIndicator/EnemyDirectionIndicator
@onready var attack_indicator_parent: Node2D = $attackIndicator
var attack_charge_time : float = 0 #this is used for attack UI, is set in attack task as export variable

func _ready() -> void:
	@warning_ignore("narrowing_conversion")
	speed = randi_range(speed - 10, speed + 10)
	
	blackboard = bt_player.blackboard
	blackboard.set_var("chase_speed", speed)  # Store enemy speed in the blackboard
	blackboard.set_var("safe_velocity", Vector2.ZERO)  # Ensure safe_velocity always exists
	blackboard.set_var("is_Attacking", false)
	#blackboard.set_var("is_knocked_back", false)
	
	health_bar.init_health(hp)
	poise_bar.init_poise(max_poise)
	
	if animated_sprite_2d.material is ShaderMaterial:
		animated_sprite_2d.material = animated_sprite_2d.material.duplicate()

func _process(_delta: float) -> void:
	#is for regaining poise when not stunned and not max poise
	if not is_stunned():
		if current_poise < max_poise and regain_poise_timer.is_stopped():
			regain_poise_timer.start()
	
	#everything below is for the Attack and Movement UI
	var isAttacking = blackboard.get_var("is_Attacking")
	if false:
		if isAttacking:
			enemy_direction_indicator.visible = false #disable walk indicator
			attack_indicator_parent.visible = true #enable the attack indicator
			pass
		else:
			attack_indicator_parent.visible = false #disable attack indicator
			update_walk_indicator() # if not attacking, update walk indicator
		

func update_attack_indicator(direction: Vector2, time_left : float) -> void:
	# calculate global target position by adding direction to the enemy's position
	var target_position = global_position + direction
	attack_indicator_parent.look_at(target_position)
	
	var charge_progress = clamp(time_left / attack_charge_time, 0.0, 1.0)
	
	# Define colors
	var start_color = Color.WHITE  # White (#FFFFFF)
	var end_color = Color("a53030")  # Red (#A53030)

	# Interpolate between white and red based on charge progress
	var current_color = start_color.lerp(end_color, 1.0 - charge_progress)

	# Get all Sprite2D children of attack_indicator_parent
	var sprites = attack_indicator_parent.get_children()

	# Determine how many sprites should be visible based on charge_progress
	var total_sprites = sprites.size()
	var visible_count = ceil(total_sprites * (1.0 - charge_progress))  # More appear as charge progresses

	for i in range(total_sprites):
		var sprite = sprites[i] as Sprite2D
		if sprite:
			sprite.visible = i < visible_count
			# Apply color change (white → red)
			sprite.modulate = current_color

func update_walk_indicator() -> void:
	if should_chase:
		enemy_direction_indicator.visible = true
		
		enemy_direction_indicator.look_at(PlayerStats.player_position)
		if global_position.distance_to(PlayerStats.player_position) <= 40:
			enemy_direction_indicator.self_modulate = Color("#a53030") #ed
		elif global_position.distance_to(PlayerStats.player_position) <= 50:
			enemy_direction_indicator.self_modulate = Color("#cf573c") #orange
		else:
			enemy_direction_indicator.self_modulate = Color.WHITE #white
	else:
		enemy_direction_indicator.visible = false

func take_damage():
	set_velocity(Vector2.ZERO)
	recently_hit_timer.start() #used for enemy behavior (rolling away)
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
	
	#everything UI and visualss
	animation_player.play("enemy_hit")
	hp -= 1
	health_bar._set_health(hp)
	
	if not is_stunned():
		current_poise = current_poise - 1*7
		if current_poise <= 0: # stun logic
			stunned_birds.visible = true
			animated_sprite_2d.play("idle")
			hit_stun_timer.start()
			poise_bar.start_poise_regeneration(hit_stun_timer.wait_time)
		
		poise_bar._set_poise(current_poise) #update poise UI
	
	if hp <= 0:
		var corpse = DEAD_SLASHER.instantiate()
		corpse.global_position = global_position
		get_tree().root.add_child(corpse)
		queue_free()

func _physics_process(_delta: float) -> void:
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
	current_poise = max_poise # not update UI since regenarate poise is called
	stunned_birds.visible = false

func is_stunned() -> bool:
	return hit_stun_timer.time_left > 0

func recently_hit() -> bool:
	return recently_hit_timer.time_left > 0


func _on_regain_poise_timer_timeout() -> void:
	current_poise += regain_poise_amount
	poise_bar.add_poise_ui(current_poise)
