extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	#should play active or reset animation bases on if is active checkpoint
	pass



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#TODO check if this checkpoint is the active checkpoint allready
		animation_player.play("active")
		
