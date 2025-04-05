extends Node2D
class_name Lamp

@export var is_on = false
@onready var inner_light: Sprite2D = $innerLight
@onready var point_light_2d: PointLight2D = $PointLight2D

#black 202e37
#orange da863e

func _ready() -> void:
	toggle(is_on) # init the lamp


func toggle(state : bool):
	if state:
		inner_light.modulate = Color("da863e")
		point_light_2d.enabled = true
	else:
		inner_light.modulate = Color("202e37")
		point_light_2d.enabled = false
		
