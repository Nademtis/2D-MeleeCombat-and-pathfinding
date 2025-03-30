extends CharacterBody2D
class_name Shooter

@onready var bow_animated_sprite_2d: AnimatedSprite2D = $bow/BowAnimatedSprite2D

#test variables
@export var rotation_speed: float = 12.0  # Adjust rotation speed

@onready var bt_player: BTPlayer = $BTPlayer
var blackboard: Blackboard

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $animatedSprite2D
@onready var stunned_birds: AnimatedSprite2D = $stunnedBirds

@onready var hit_stun_timer: Timer = $hitStunTimer #when enemy is hit, trigger the timer
@onready var can_be_stunned_again_timer: Timer = $canBeStunnedAgainTimer

const DEAD_SLASHER = preload("res://enemy/slasher/dead_slasher.tscn")
@onready var health_bar: HealthBar= $healthBar
@onready var poise_bar: PoiseBar= $PoiseBar

#enemy stats
@export var speed: float = 70
@export var hp: float = 5
@export var max_poise: float = 30
@export var regain_poise_amount : float = 0.5
var current_poise = max_poise
@onready var regain_poise_timer: Timer = $regainPoiseTimer
@onready var recently_hit_timer: Timer = $recentlyHitTimer

#combat
var is_aggroed = false
@export var ranged_attack_charge_time : float = 3

# Knockback variables
@export var knockback_duration: float = 0.05
@export var knockback_strength = 150
var knockback_force: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func _ready() -> void:
	health_bar.init_health(hp)
	poise_bar.init_poise(max_poise)
	
	blackboard = bt_player.blackboard
	blackboard.set_var("is_charging_attack", false)
	
	if animated_sprite_2d.material is ShaderMaterial:
		animated_sprite_2d.material = animated_sprite_2d.material.duplicate()

func _process(delta: float) -> void:
	#is for regaining poise when not stunned and not max poise
	if not is_stunned():
		if current_poise < max_poise and regain_poise_timer.is_stopped():
			regain_poise_timer.start()
	
	#this below is for shooting, and should not be here, should be in Btree
	point_bow_towards_player(delta)
	bow_y_sort()
	
	if blackboard.get_var("is_charging_attack") == true:
		bow_animated_sprite_2d.visible = true
	else:
		animated_sprite_2d.play("idle")
		bow_animated_sprite_2d.visible = false
		
	#if PlayerStats.player_position.x < global_position.x:
		#animated_sprite_2d.play("attack_left")
	#else:
		#animated_sprite_2d.play("attack_right")
		

func _physics_process(_delta: float) -> void:
	if knockback_timer > 0:
		velocity = knockback_force
		knockback_timer -= _delta
		
		# Gradually reduce knockback force (smooth stop)
		knockback_force = knockback_force.lerp(Vector2.ZERO, _delta * 10)
	else:
		pass
		knockback_force = Vector2.ZERO
		velocity = velocity.lerp(Vector2.ZERO, _delta * 8)
		
	move_and_slide()

func point_bow_towards_player(delta: float)-> void:
	var direction = (PlayerStats.player_position - global_position).normalized()
	var target_angle = direction.angle()
	# Offset correction if the arrow points up by default
	target_angle += deg_to_rad(-90)
	# Smoothly rotate towards the target angle
	bow_animated_sprite_2d.rotation = lerp_angle(bow_animated_sprite_2d.rotation, target_angle, rotation_speed * delta)

func bow_y_sort() -> void:
	if PlayerStats.player_position.y > global_position.y:
		bow_animated_sprite_2d.z_index = 1
	else:
		bow_animated_sprite_2d.z_index = 0
		
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
	
	#apply camera shake
	Events.emit_signal("combat_camera_shake")
	
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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		take_damage()


func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_aggroed = true
