extends CharacterBody2D
class_name enemy

@export var speed: float = 70
@export var hp: float = 5
var should_walk = false
@export var should_chase = false

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var player: Node2D = get_node("/root/main/player")
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	speed = randi_range(speed - 10 ,speed + 10)
	
func take_damage():
	set_velocity(Vector2.ZERO)
	animation_player.play("enemy_hit")
	hp = hp - 1
	if hp <= 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	if should_chase:
		movement()

#only chase after some timeout
func _on_start_nav_timeout() -> void:
	should_walk = true
	navigation_agent_2d.target_position = player.global_position

#used for avoidance
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	var delta = 1.0 / Engine.physics_ticks_per_second
	velocity = velocity.lerp(safe_velocity, 5 * delta)
	move_and_slide()

func movement():
	if not player or not should_walk:
		return
	navigation_agent_2d.target_position = player.global_position
	var direction = navigation_agent_2d.get_next_path_position() - global_position
	direction = direction.normalized()
	
	var intended_velocity = direction * speed
	navigation_agent_2d.velocity = intended_velocity
	#velocity = velocity.lerp(direction * speed, 5 * delta) #Smoother turning
	#move_and_slide()
	#navigation_agent_2d.velocity = velocity

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		take_damage()
