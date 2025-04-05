extends Node2D
#door 

#door coll shape. if door is closed -> disabled = false
@onready var door_coll_shape: CollisionShape2D = $doorStaticBody2D2/doorCollShape


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

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.get_animation() == "open":
		door_coll_shape.disabled = true
	else:
		door_coll_shape.disabled = false
