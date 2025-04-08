extends Node2D
class_name PlayerSFX

@onready var player: Player = $".."
#var movestate : Player.MovementState

#walking
@onready var step_playlist: AudioStreamPlayer2D = $stepPlaylist
@onready var attackSFX: AudioStreamPlayer2D = $attackSFX
@onready var dashSFX: AudioStreamPlayer2D = $dashSFX

func _ready() -> void:
	pass
	#movestate = player.movement_state

func _process(delta: float) -> void:
	player_walking()
	
func dash() -> void:
	SFXutil.play_with_pitch(dashSFX, 1.25, 1.55)

func attack() -> void:
	SFXutil.play_with_pitch(attackSFX)

func player_walking() -> void:
	#print("movestate from SFX ",Player.MovementState.keys()[player.movement_state])
	if player.movement_state == Player.MovementState.WALKING:
		if step_playlist.playing == false:
			step_playlist.play()
	else:
		step_playlist.stop()
		#print("stopped")
