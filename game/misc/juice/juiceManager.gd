extends CanvasLayer

@onready var player_hit_vignette: ColorRect = $playerHitVignette
@onready var vignette_material: ShaderMaterial = player_hit_vignette.material

func _ready() -> void:
	Events.connect("player_hit", turn_on_red_vignette)
	
func turn_on_red_vignette() -> void:
	player_hit_vignette.visible = true
	vignette_material.set_shader_parameter("vignette_opacity", 1.0)  # Set full opacity
	
	var tween := create_tween()
	tween.tween_method(set_vignette_opacity, 1.0, 0.0, 0.5)  # Fade to 0 over 0.5s
	
	await tween.finished
	player_hit_vignette.visible = false
	

func set_vignette_opacity(value: float) -> void:
	vignette_material.set_shader_parameter("vignette_opacity", value)
