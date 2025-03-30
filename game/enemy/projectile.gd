extends Node2D
class_name Projectile

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box_area_2d: Area2D = $hitBoxArea2D


@onready var kill_timer: Timer = $killTimer

@export var damage : float
@export var travel_speed : float
@export var direction : Vector2


func setup_projectile(p_damage : float, p_travel_speed : float, p_direction : Vector2) -> void:
	damage = p_damage
	travel_speed = p_travel_speed
	direction = p_direction
	rotation = direction.angle()


func _process(delta: float) -> void:
	global_position += direction.normalized() * travel_speed * delta


func _on_kill_timer_timeout() -> void:
	#for when projectile has been alive for too long
	queue_free()


func _on_hit_box_area_2d_body_entered(body: Node2D) -> void:
	queue_free()
	pass # Replace with function body.


func _on_hit_box_area_2d_area_entered(area: Area2D) -> void:
	queue_free()
	pass # Replace with function body.
