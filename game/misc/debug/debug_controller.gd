extends Node

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)

func _input(event: InputEvent) -> void:
	#can have debug input things
	pass
