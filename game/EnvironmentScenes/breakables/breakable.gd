extends Node2D
#breakable
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var sprite: Sprite2D = $Sprite
@onready var move_coll: CollisionShape2D = $moveColl


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		if gpu_particles_2d.emitting == false: #so it can't be triggered twice
			gpu_particles_2d.emitting = true
			
			move_coll.set_deferred("disabled",true)
			sprite.visible = false
		#queue_free()
		pass

	#for enemy destroying	
	#if area.is_in_group("enemy_attack"):
		##particles should spawn
		##queue_free()
		#pass


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
	pass # Replace with function body.
