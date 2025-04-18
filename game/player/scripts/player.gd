extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#player movement
@export var max_speed: float = 75
@export var acceleration: float = 12
@export var deceleration: float = 95

#hp and state
var is_dead = false

#input
var left_click_held_down = false
var dash_held_down = false

#player attack & combo
var can_attack: bool = true
var combo_count : int = 0
var max_combo : int = 3
@onready var attack_small_delay: Timer = $attackDelay #timewindow to make combo
@onready var attack_cool_down: Timer = $attackCoolDown # cooldown between attacks
@onready var attack_combo: Timer = $attackCombo

#attackCollisions
@onready var coll_shape_left: CollisionPolygon2D = $attackHitbox/CollShapeLeft/collShapeLeft
@onready var coll_shape_right: CollisionPolygon2D = $attackHitbox/CollShapeRight/collShapeRight
@onready var coll_shape_up: CollisionPolygon2D = $attackHitbox/CollShapeUp/collShapeUp
@onready var coll_shape_down: CollisionPolygon2D = $attackHitbox/CollShapeDown/collShapeDown

#check for stair
@onready var ground_tilemap: TileMapLayer = %ground
var last_tile_under_player: Vector2i

#player dash
@export var dash_speed: float = 550 #500
@export var dash_duration : float = 0.13 # 0.1
var can_dash = true
var quick_dash_after_attack = true
var dash_direction : Vector2
var dash_elapsed_time : float = 0.0
var dash_start_speed : float
@onready var dash_cooldown: Timer = $dashCooldown

#below is used for the attack dash
@export var attack_dash_speed: float = 225
@export var attack_dash_duration: float = 0.1
var attack_dash_target_position: Vector2
var attack_dash_elapsed_time: float = 0.0
var attack_dash_direction: Vector2 = Vector2.ZERO

#ui
@onready var health_bar: HealthBar = %healthBar
@onready var canvas_layer: CanvasLayer = $CanvasLayer

#used when dashing -turning on and off
@onready var hurtbox_coll: CollisionShape2D = $hurtbox/hurtboxColl

enum MovementState{IDLE, WALKING, ATTACKING, DASHING}
var movement_state = MovementState.IDLE
@onready var sfx: PlayerSFX = $audio


func _ready() -> void:
	Events.connect("player_attacked", setup_attack_dash) #TODO
	Events.connect("player_hp_changed", update_hp_ui)
	Events.connect("immobilize_player", player_died)
	
	#this is only to not show the healthbar in main scene
	canvas_layer.visible = true
	
	var player_hp_node: PlayerHP = $hp  # Reference to the hp node
	health_bar.init_health(player_hp_node.hp, true)  # Set initial health

func _process(_delta: float) -> void:
	if is_dead:
		return
		
	PlayerStats.player_position = global_position #update player position for global access
	#PlayerStats.player_velocity = velocity
	
	#set idle if not attack and dashing and not moving
	#if movement_state != MovementState.ATTACKING and movement_state != MovementState.DASHING:
		#if PlayerStats.player_input_vector == Vector2.ZERO:
			#set_movement_state(MovementState.IDLE)
	
	#disable hurtbox when dashing
	if movement_state == MovementState.DASHING:
		hurtbox_coll.disabled = true
	else:
		hurtbox_coll.disabled = false
	
	left_click_held_down = Input.is_action_pressed("click")
	dash_held_down = Input.is_action_pressed("dash")
	anim_player()
	
	if Input.is_action_pressed("click") && can_attack or left_click_held_down && can_attack:
		var point = get_global_mouse_position()
		var direction = point - global_position
		setup_attack_dash(direction)
		attack(point)
	
	#dashing
	if Input.is_action_pressed("dash") && can_dash or dash_held_down && can_dash:
		if movement_state == MovementState.WALKING:
			setup_dash()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	#var stair_direction : String = check_for_stairs()
	#print(stair_direction)
	#print(MovementState.keys()[movement_state])

	match movement_state:
		MovementState.WALKING, MovementState.IDLE:
			move_player(delta)
		MovementState.ATTACKING:
			handle_attack_dash(delta)
		MovementState.DASHING:
			handle_dashing(delta)

	move_and_slide()

func check_for_stairs() -> String:
	var current_tile: Vector2i = ground_tilemap.local_to_map(global_position + Vector2(0, 8))
	var tile_data := ground_tilemap.get_cell_tile_data(current_tile)
	
	if tile_data:
		var stair_direction = tile_data.get_custom_data("stairDirection")  # Get the stair direction from the tile
		return stair_direction  # Return the direction ("left", "right", "middle")
	return ""  # Return an empty string if not on stairs

func attack(_point : Vector2):
	var attack_direction = get_attack_direction()
	match combo_count:
		0:
			animated_sprite_2d.play("attack_1_" + attack_direction)
		1:
			animated_sprite_2d.play("attack_2_" + attack_direction)
		2:
			animated_sprite_2d.play("attack_1_" + attack_direction) #todo should be 3 - need animation
		
	turn_on_attack_collision(attack_direction)
	combo_count += 1
	can_attack = false
	
	
	if combo_count >= max_combo:
		Events.emit_signal("freeze_frame", 0.15, 0.5) ##freeze_frame(0.15, 0.25)
		attack_cool_down.start()
	else:
		attack_small_delay.start()
		attack_combo.start()

func setup_attack_dash(direction: Vector2):
	set_movement_state(MovementState.ATTACKING)
	sfx.attack()
	attack_dash_direction = direction.normalized()
	attack_dash_elapsed_time = 0.0  # Reset timer
	
func handle_attack_dash(delta: float):
	attack_dash_elapsed_time += delta
	var t = attack_dash_elapsed_time / attack_dash_duration
	t = clamp(t, 0, 1)

	velocity = attack_dash_direction * attack_dash_speed * (1 - t)

	if t >= 1.0:
		velocity = Vector2.ZERO

func setup_dash():
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	if input_vector != Vector2.ZERO:
		set_movement_state(MovementState.DASHING)
		dash_direction = input_vector
		dash_elapsed_time = 0.0 # Reset timer
		dash_start_speed = dash_speed  # Store initial speed
		dash_cooldown.start()
		can_dash = false
		sfx.dash()
		ParticleFX.spawn_dash_effect(dash_direction, global_position, 0.50)

func handle_dashing(delta: float):
	dash_elapsed_time += delta
	var t = clamp(dash_elapsed_time / dash_duration, 0, 1)

	# Smoothly reduce velocity using lerp
	velocity = lerp(dash_start_speed, 0.0, t) * dash_direction

	if t >= 1.0:
		velocity = Vector2.ZERO
		set_movement_state(MovementState.WALKING)

func set_movement_state(new_state : MovementState):
	#var old_state: MovementState = movement_state
	#print(MovementState.keys()[new_state])
	match new_state:
		MovementState.IDLE:
			movement_state = MovementState.IDLE
		MovementState.WALKING:
			movement_state = MovementState.WALKING
		MovementState.ATTACKING:
			movement_state = MovementState.ATTACKING
		MovementState.DASHING:
			movement_state = MovementState.DASHING
			

func move_player(delta):
	#var direction: Vector2 = Vector2.ZERO
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	PlayerStats.player_input_vector = input_vector
	
	# apply acceleration when input is detected
	if input_vector != Vector2.ZERO:
		velocity = lerp(velocity, input_vector * max_speed, acceleration * delta)
		set_movement_state(MovementState.WALKING)
	else: # Apply deceleration when no input is detected
		velocity = lerp(velocity, input_vector * max_speed, deceleration * delta)
		set_movement_state(MovementState.IDLE)
	
	# Check if the player is on stairs
	var stair_direction = check_for_stairs()
	
	if stair_direction != "":
		if stair_direction == "right": 
			if input_vector.x > 0:  # Moving right on right stairs
				velocity.y = lerp(velocity.y, velocity.y - max_speed / 4, 0.75)  # Add bias to make the player move diagonally upward right
			elif input_vector.x < 0:  # Moving left on right stairs
				velocity.y = lerp(velocity.y, velocity.y + max_speed / 4, 0.75)  # Add bias to make the player move diagonally downward left

		elif stair_direction == "left":
			if input_vector.x < 0:  # Moving left on left stairs
				velocity.y = lerp(velocity.y, velocity.y - max_speed / 4, 0.75)  # Add bias to make the player move diagonally upwards
			elif input_vector.x > 0:  # Moving right on left stairs
				velocity.y = lerp(velocity.y, velocity.y + max_speed / 4, 0.75)  # Add bias to make the player move diagonally downward
		velocity *= 0.95
	elif stair_direction == "middle":
		# No vertical adjustment for middle stairs, you could add more logic here if needed
		pass

func anim_player():
	#if animated_sprite_2d.animation == "attack_1_right" || animated_sprite_2d.animation == "attack_2_right":
	#	return
	if movement_state == MovementState.ATTACKING:
		return

	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				animated_sprite_2d.play("walk_right")
			else:
				animated_sprite_2d.play("walk_left")
		else:
			if input_vector.y > 0:
				animated_sprite_2d.play("walk_down")
			else:
				animated_sprite_2d.play("walk_up")
	else:
		animated_sprite_2d.play("idle_down")  # Default idle animation

func get_attack_direction() -> String:
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	var angle_degrees = rad_to_deg(atan2(direction.y, direction.x))

	# Normalize angle to be between 0 and 360
	angle_degrees = fposmod(angle_degrees + 360, 360)

	# Determine attack direction based on 4 quadrants
	if angle_degrees >= 45 && angle_degrees < 135:
		return "down"
	elif angle_degrees >= 135 && angle_degrees < 225:
		return "left"
	elif angle_degrees >= 225 && angle_degrees < 315:
		return "up"
	else:
		return "right"

func player_died()-> void:
	is_dead = true
	hurtbox_coll.set_deferred("disabled", true)  # Disable collision
	#animated_sprite_2d.play("death")#
	

func turn_on_attack_collision(direction: String):
	match direction:
		"up":
			coll_shape_up.disabled = false
		"down":
			coll_shape_down.disabled = false
		"right":
			coll_shape_right.disabled = false
		"left":
			coll_shape_left.disabled = false
	await get_tree().create_timer(0.05).timeout
	coll_shape_up.disabled = true
	coll_shape_down.disabled = true
	coll_shape_right.disabled = true
	coll_shape_left.disabled = true

func _on_attack_cool_down_timeout() -> void: 
	#attack and combo finished - go back to walking
	can_attack = true
	combo_count = 0
	pass

func _on_attack_delay_timeout() -> void:
	if attack_cool_down.time_left > 0:
		print("combo ended starting longer cooldown")
		return
	else:
		can_attack = true

func _on_attack_combo_timeout() -> void:
	#combo reset if no attack - checking if other cooldown are ongoing before resetting
	if not attack_small_delay.time_left > 0 && not attack_cool_down.time_left > 0 :
		#push_warning("no attack, resetting combo")
		combo_count = 0

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation.begins_with("attack_"):
		#print(animated_sprite_2d.animation + " finished")
		set_movement_state(MovementState.WALKING)

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	pass # Replace with function body.

func update_hp_ui(new_hp : float)-> void:
	health_bar._set_health(new_hp)
