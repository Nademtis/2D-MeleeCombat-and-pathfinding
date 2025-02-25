extends ProgressBar
class_name PoiseBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $damageBar

var poise: float : set = _set_poise


func init_poise(_poise : float) -> void:
	poise = _poise
	max_value = poise
	value = poise
	damage_bar.max_value = poise
	damage_bar.value = poise
	visible = false

func _set_poise(new_poise):
	var prev_poise = poise
	poise = new_poise
	value = poise
	visible = true
	
	if poise < prev_poise:
		timer.start()
	else:
		damage_bar.value = poise

func add_poise_ui(new_poise) -> void:
	poise = new_poise
	value = poise

func start_poise_regeneration(duration: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "value", max_value, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(damage_bar, "value", max_value, duration).set_trans(Tween.TRANS_LINEAR)

func _on_timer_timeout() -> void:
	damage_bar.value = poise
