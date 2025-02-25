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
	poise = min(max_value, new_poise)
	value = poise
	visible = true
	
	if poise < prev_poise:
		timer.start()
	else:
		damage_bar.value = poise

func _on_timer_timeout() -> void:
	damage_bar.value = poise
