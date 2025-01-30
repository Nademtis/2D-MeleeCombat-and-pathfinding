extends CharacterBody2D
class_name enemy

@export var speed: float = 70
var should_walk = false

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var player: Node2D = get_node("/root/main/player")

func _ready() -> void:
	speed = randi_range(speed - 10 ,speed + 10)
func _physics_process(delta: float) -> void:
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

func _on_start_nav_timeout() -> void:
	should_walk = true
	navigation_agent_2d.target_position = player.global_position
	pass # Replace with function body.


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	var delta = 1.0 / Engine.physics_ticks_per_second
	velocity = velocity.lerp(safe_velocity, 5 * delta)
	move_and_slide()
