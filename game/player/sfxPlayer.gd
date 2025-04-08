extends Node2D

@onready var player: Player = $".."
#var movestate : Player.MovementState

#walking
@onready var step_playlist: AudioStreamPlayer2D = $stepPlaylist

func _ready() -> void:
	pass
	#movestate = player.movement_state

func _process(delta: float) -> void:
	player_walking()
	

func player_walking() -> void:
	print("movestate from SFX ",Player.MovementState.keys()[player.movement_state])
	
	if player.movement_state == Player.MovementState.WALKING:
		if step_playlist.playing == false:
			step_playlist.play()
	else:
		step_playlist.stop()
		print("stopped")
