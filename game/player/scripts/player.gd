extends CharacterBody2D

@export var max_speed: float = 100
@export var acceleration: float = 2800
@export var deceleration: float = 800

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	move_player(delta)
	anim_player()
	
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
	
