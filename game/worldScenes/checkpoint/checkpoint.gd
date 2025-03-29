extends Area2D
#this is attached the checkpointScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var level_name : String #is the level name


func _ready() -> void:
	level_name = get_tree().root.name
	print("levelName:", level_name)
	#should play active or reset animation bases on if is active checkpoint
	pass



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		CheckpointManager.set_active_checkpoint(level_name, global_position)
		print("active")
		#TODO check if this checkpoint is the active checkpoint allready
		animation_player.play("active")
		
