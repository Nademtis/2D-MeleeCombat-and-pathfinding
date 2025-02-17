extends ProgressBar
class_name HealthBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $damageBar

var hp: float : set = _set_health


func init_health(_health : float, _isVisible:bool = false) -> void:
	hp = _health
	max_value = hp
	value = hp
	damage_bar.max_value = hp
	damage_bar.value = hp
	visible = _isVisible

func _set_health(new_hp):
	var prev_hp = hp
	hp = min(max_value, new_hp)
	value = hp
	visible = true
	
	if hp < prev_hp:
		timer.start()
	else:
		damage_bar.value = hp

func _on_timer_timeout() -> void:
	damage_bar.value = hp
