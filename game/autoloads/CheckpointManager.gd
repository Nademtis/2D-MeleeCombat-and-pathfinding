extends Node
#CheckpointManager

var active_checkpoint: Checkpoint

func set_active_checkpoint(new_checkpoint: Checkpoint) -> void:
	active_checkpoint = new_checkpoint
	Events.emit_signal("new_active_checkpoint")

func get_active_checkpoint() -> Checkpoint:
	return active_checkpoint
