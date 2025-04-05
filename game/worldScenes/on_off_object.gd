extends Node2D
class_name OnOffObject

@export var is_on : bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var color_rect: ColorRect = $AnimatedSprite2D/ColorRect #highlight shader

@export var optional_lamp : Lamp = null
#TODO optional lamp 

signal toggled(new_state: bool)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		#todo camera shake?
		is_on = !is_on
		if is_on:
			turn_on()
		else:
			turn_off()
		emit_signal("toggled", is_on)
		
		if optional_lamp:
			optional_lamp.toggle(is_on)
		
func turn_on() -> void:
	animated_sprite_2d.play("turn_on")
	color_rect.material.set_shader_parameter("Speed", 0.0)
	
func turn_off() -> void:
	animated_sprite_2d.play("turn_off")
	color_rect.material.set_shader_parameter("Speed", 0.35)
