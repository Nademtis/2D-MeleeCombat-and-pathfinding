extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#player movement
@export var max_speed: float = 100
@export var acceleration: float = 2800
@export var deceleration: float = 800

#player attack dash
@export var attack_dash_speed: float = 5
@export var attack_dash_duration: float = 0.1
#var is_dashing = false

enum MovementState{WALKING, ATTACKING, DASHING}
var movement_state = MovementState.WALKING

func _ready() -> void:
	Events.connect("player_attacked", attack_dash) #TODO
	pass
	

func _process(delta: float) -> void:
	match movement_state:
		MovementState.WALKING:
			move_player(delta)
		MovementState.ATTACKING:
			
			pass
		MovementState.DASHING:
			pass
		
	anim_player()

func attack_dash(direction : Vector2):
	set_movement_state(MovementState.ATTACKING)
	
func set_movement_state(new_state : MovementState):
	var old_state = movement_state
	
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
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	# Apply deceleration when no input is detected
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	# Move the player
	move_and_slide()

func anim_player():
	if velocity.x > 0: # Moving right
		animated_sprite_2d.play("right")
	elif velocity.x < 0: # Moving left
		animated_sprite_2d.play("left")
	else: # Idle (no horizontal movement)
		animated_sprite_2d.play("idle")
	


func _on_attack_cool_down_timeout() -> void:
	#attack finished - go back to walking
	set_movement_state(MovementState.WALKING)
