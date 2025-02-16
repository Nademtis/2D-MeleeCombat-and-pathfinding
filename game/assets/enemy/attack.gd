extends Node2D

#@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var animation_player2: AnimationPlayer = $"new attack/AnimationPlayer"


#TODO not used currently

func initialize(is_attack_right: bool) -> void:
	pass
	#attack_right = is_attack_right

func _ready() -> void:
	pass
	##if attack_right:
		##animation_player.play("attack_R")
	##else:
		##animation_player.play("attack_L")
		##
	#if attack_right:
		#sprite_2d.flip_h = false
		##animation_player2.play("attack")
	#else:
		#sprite_2d.flip_h = true
		##animation_player2.play("attack")
		#


#TODO IF HIT --> object take damage --> kill this

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_kill_timer_timeout() -> void:
	queue_free()
	
	pass # Replace with function body.
