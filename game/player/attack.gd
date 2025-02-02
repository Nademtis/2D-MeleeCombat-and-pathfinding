extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var attack_right = true

func initialize(is_attack_right: bool) -> void:
	attack_right = is_attack_right

func _ready() -> void:
	if attack_right:
		animation_player.play("attack_R")
	else:
		animation_player.play("attack_L")
		

#TODO IF HIT --> object take damage --> kill this

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
