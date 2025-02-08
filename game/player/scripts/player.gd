extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#player movement
@export var max_speed: float = 85 #100
@export var acceleration: float = 60 #2000
@export var deceleration: float = 80 #500

#input
var left_click_held_down = false

#player attack & combo
var can_attack: bool = true
var combo_count : int = 0
var max_combo : int = 3
@onready var attack_small_delay: Timer = $attackDelay #timewindow to make combo
@onready var attack_cool_down: Timer = $attackCoolDown # cooldown between attacks
@onready var attack_combo: Timer = $attackCombo

#collisions
@onready var coll_shape_left: CollisionPolygon2D = $attackHitbox/CollShapeLeft/collShapeLeft
@onready var coll_shape_right: CollisionPolygon2D = $attackHitbox/CollShapeRight/collShapeRight
@onready var coll_shape_up: CollisionPolygon2D = $attackHitbox/CollShapeUp/collShapeUp
@onready var coll_shape_down: CollisionPolygon2D = $attackHitbox/CollShapeDown/collShapeDown

#player attack dash
@export var attack_dash_speed: float = 225
@export var attack_dash_duration: float = 0.06

#below is used for the attack dash
var attack_dash_start_position: Vector2
var attack_dash_target_position: Vector2
var attack_dash_elapsed_time: float = 0.0
var attack_dash_direction: Vector2 = Vector2.ZERO

enum MovementState{WALKING, ATTACKING, DASHING}
var movement_state = MovementState.WALKING

func _ready() -> void:
	Events.connect("player_attacked", attack_dash) #TODO

func _process(_delta: float) -> void:
	PlayerStats.player_position = global_position #update player position for enemies
	left_click_held_down = Input.is_action_pressed("click")
	anim_player()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click" ) && can_attack or left_click_held_down && can_attack :
		var point = get_global_mouse_position()
		var direction = point - global_position
		attack_dash(direction)
		attack(point)

func _physics_process(delta: float) -> void:
	match movement_state:
		MovementState.WALKING:
			move_player(delta)
		MovementState.ATTACKING:
			handle_attack_dash(delta)
			pass
		MovementState.DASHING:
			pass
	move_and_slide()
	

func attack_dash(direction: Vector2):
	set_movement_state(MovementState.ATTACKING)
	attack_dash_start_position = global_position
	attack_dash_direction = direction.normalized()
	attack_dash_target_position = attack_dash_start_position + attack_dash_direction * (attack_dash_speed * attack_dash_duration)
	attack_dash_elapsed_time = 0.0  # Reset timer

func attack(point : Vector2):
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
		#freeze_frame(0.15, 0.25)
		attack_cool_down.start()
	else:
		attack_small_delay.start()
		attack_combo.start()

func handle_attack_dash(delta: float):
	attack_dash_elapsed_time += delta
	var t = attack_dash_elapsed_time / attack_dash_duration  # Normalized time (0 to 1)
	t = clamp(t, 0, 1)  # Ensure t stays within bounds

	# Lerp the player's position smoothly
	global_position = attack_dash_start_position.lerp(attack_dash_target_position, t)

	# Dash complete
	if t >= 1.0:
		pass
		#set_movement_state(MovementState.WALKING)

func set_movement_state(new_state : MovementState):
	#var old_state: MovementState = movement_state
	#print(MovementState.keys()[new_state])
	
	match new_state:
		MovementState.WALKING:
			movement_state = MovementState.WALKING
			
		MovementState.ATTACKING:
			#max_speed = max_speed * 0.25 #lerp this value back up to 1.0
			movement_state = MovementState.ATTACKING
			pass
			
		MovementState.DASHING:
			pass

func move_player(delta):
	#var direction: Vector2 = Vector2.ZERO
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	# apply acceleration when input is detected
	if input_vector != Vector2.ZERO:
		velocity = lerp(velocity, input_vector * max_speed, acceleration * delta)
	else: # Apply deceleration when no input is detected
		velocity = lerp(velocity, input_vector * max_speed, deceleration * delta)

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

func freeze_frame(duration: float, slow_motion_scale: float = 0.0) -> void:
	print("freezing")
	#Engine.time_scale = slow_motion_scale
	#await get_tree().create_timer(duration, false).timeout  # Run timer in unscaled time
	#Engine.time_scale = 1.0  # Restore normal speed
	Engine.time_scale = slow_motion_scale
	await(get_tree().create_timer(duration, true, false, true).timeout)
	Engine.time_scale = 1
	
	

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
