extends Node
#global MusicManager
#@onready var music_player: AudioStreamPlayer = $musicPlayer_3

@onready var music_player_0: AudioStreamPlayer = $musicPlayer_0
@onready var music_player_1: AudioStreamPlayer = $musicPlayer_1
@onready var music_player_2: AudioStreamPlayer = $musicPlayer_2

var current_audio_player : AudioStreamSynchronized
var current_audio_player_index : int = 0



func _ready() -> void:
	get_current_audio_player().play()
	
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("k"):
		##level_up(true)
		#print(get_current_audio_player())
		#print("current level ", current_audio_player_index)
	#if event.is_action_pressed("l"):
		#level_up(true)


func level_up(on : bool) -> void:
	#turn on the next stream in the current audiostreamplayer, if there are no more streams
	#turn this stream off, and turn on the next audiostreampalyer with only the first stream enabled.
	get_current_audio_player().stop()
	current_audio_player_index += 1
	get_current_audio_player().play()


func get_current_audio_player() -> AudioStreamPlayer:
	match current_audio_player_index:
		0:
			return music_player_0
		1:
			return music_player_1
		2:
			return music_player_2
		_:
			return music_player_2 # todo not like this
