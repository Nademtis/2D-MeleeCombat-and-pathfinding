extends Node2D
#breakable
@onready var gpu_particles_2d: GPUParticles2D = $breakablePS
@onready var sprite: Sprite2D = $Sprite
@onready var move_coll: CollisionShape2D = $moveColl

func _ready() -> void:
	gpu_particles_2d.connect("finished", _on_gpu_particles_2d_finished)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack") or area.is_in_group("enemy_attack"):
		if gpu_particles_2d.emitting == false: #so it can't be triggered twice
			setup_PS()
			var direction = (global_position - area.global_position).normalized()
			gpu_particles_2d.process_material.set("direction", direction)
			
			gpu_particles_2d.emitting = true
			
			move_coll.set_deferred("disabled", true)
			sprite.visible = false
		#queue_free()
		pass

func _on_gpu_particles_2d_finished() -> void:
	queue_free()

func setup_PS()->void:
	gpu_particles_2d.set_amount(randi_range(8,15))
