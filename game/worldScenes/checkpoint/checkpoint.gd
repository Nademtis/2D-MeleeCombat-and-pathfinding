extends Area2D
#this is attached the checkpointScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var level_name : String

func _ready() -> void:
	#level_name = LevelManager.get_active_level_name()
	level_name = get_parent().get_parent().name # might be to hardcoded
	
	print("from checkpoint my level name is: ", level_name)
	#print("levelName:", level_name)
	#should play active or reset animation bases on if is active checkpoint
	pass



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var new_checkpoint: Checkpoint = Checkpoint.new(level_name, global_position)
		var active_checkpoint = CheckpointManager.get_active_checkpoint()
		
		if active_checkpoint == null or not active_checkpoint.is_same_as(new_checkpoint):
			print("not the same")
			CheckpointManager.set_active_checkpoint(new_checkpoint)
			animation_player.play("active")
		else:
			print("the same")
