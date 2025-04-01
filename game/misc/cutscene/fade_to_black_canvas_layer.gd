extends CanvasLayer

@onready var black_overlay_texture_rect: ColorRect = $blackOverlayTextureRect

func _ready() -> void:
	Events.connect("new_level_loaded", play_intro_cutscene)
	Events.connect("fade_to_black", fade_to_black)

func play_intro_cutscene() -> void:
	black_overlay_texture_rect.visible = true
	
	var tween = get_tree().create_tween()
	# First tween (small radius)
	tween.tween_property(black_overlay_texture_rect.material, "shader_parameter/radius", 0.15, 0.5)
	tween.tween_interval(0.25)  # Wait for 1 second
	# Second tween (large radius)
	tween.tween_property(black_overlay_texture_rect.material, "shader_parameter/radius", 1.5, 3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	black_overlay_texture_rect.visible = false  # Hide when done

func fade_to_black(duration : float) -> void:
	black_overlay_texture_rect.material.set_shader_parameter("radius", 1.5)
	black_overlay_texture_rect.visible = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(black_overlay_texture_rect.material, "shader_parameter/radius", 0.0, duration) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN)
	
	await tween.finished
