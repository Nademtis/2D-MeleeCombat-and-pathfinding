extends Node2D
#door 


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var triggers : Array[OnOffObject]
@onready var interactable: Interactable = $interactable

func _ready() -> void:
	interactable.triggers = triggers
	interactable.enabled_changed.connect(open_door)
	interactable.initialize()

func open_door(state : bool) -> void:
	if state:
		animated_sprite_2d.play("open")
	else:
		animated_sprite_2d.play("close")

		
