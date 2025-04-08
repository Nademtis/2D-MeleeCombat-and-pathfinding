extends Node
# global SFXutil

func play_with_pitch(audio_stream : AudioStreamPlayer2D, pitch_low : float = 0.95, pitch_high : float = 1.05) -> void:
	var new_pitch : float = randf_range(pitch_low, pitch_high)
	audio_stream.set_pitch_scale(new_pitch)
	audio_stream.play()
