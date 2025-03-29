extends Area2D
#this is attached the checkpointScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var level_name : String

func _ready() -> void:
	Events.connect("new_active_checkpoint", am_i_active)
	level_name = get_parent().get_parent().name # might be too hardcoded
	am_i_active()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var new_checkpoint: Checkpoint = Checkpoint.new(level_name, global_position)
		var active_checkpoint = CheckpointManager.get_active_checkpoint()
		
		if active_checkpoint == null or not active_checkpoint.is_same_as(new_checkpoint):
			print("not the same")
			CheckpointManager.set_active_checkpoint(new_checkpoint)
			animation_player.play("active")


func am_i_active() -> void:
	var this_checkpoint = Checkpoint.new(level_name, global_position)
	if this_checkpoint.is_same_as(CheckpointManager.get_active_checkpoint()):
		animation_player.play("active")
	else:
		animation_player.play("RESET")
