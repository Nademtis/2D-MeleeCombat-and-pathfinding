extends Node2D
class_name axe

@onready var attack_cool_down: Timer = $attackCoolDown
#const ATTACK = preload("res://player/attack.tscn")
var can_attack = true

#TODO not used currently

func _on_attack_cool_down_timeout() -> void:
	can_attack = true
	pass # Replace with function body.

#func _input(event):
	#if event.is_action_pressed("click"):
		#if (can_attack):
			#attack(true)
	#if event.is_action_pressed("rightClick"):
		#if (can_attack):
			#attack(false)

#func attack(attack_right: bool):
	#var point = get_global_mouse_position()
	##var attack_instance = ATTACK.instantiate() #error here
	#
	##setup right or left
	#if attack_right:
		#attack_instance.initialize(true)
	#else:
		#attack_instance.initialize(false)
		#
	#
	#var direction = point - global_position
	#Events.emit_signal("player_attacked", direction)
	#
	#var angle_radians = direction.angle()
	#attack_instance.rotation = angle_radians + PI
#
	##cooldown stuff
	#can_attack = false
	##attack_cool_down.start()
#
	#add_child(attack_instance)
	#await get_tree().create_timer(1).timeout
	#attack_instance.queue_free()
