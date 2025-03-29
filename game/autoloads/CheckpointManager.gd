extends Node
#CheckpointManager

var active_checkpoint: Checkpoint

func set_active_checkpoint(level_name: String, position: Vector2) -> void:
	active_checkpoint = Checkpoint.new(level_name, position)

func get_active_checkpoint() -> Checkpoint:
	return active_checkpoint
