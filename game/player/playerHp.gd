extends Node
class_name PlayerHP
@export var hp : float = 10

@onready var invincible_timer: Timer = $"../invincibleTimer"
@onready var player: Player = $".."

var blink_tween : Tween

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("k"): #only for debug - player takes damage
		pass
		#take_damage(1)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		if invincible_timer.is_stopped():
			take_damage(1)
	
func take_damage(damage_taken:float) -> void:
	hp -= damage_taken
	Events.emit_signal("player_hp_changed", hp)
	
	Events.emit_signal("player_hit")
	Events.emit_signal("freeze_frame", 1, 0.25)
	
	if hp <= 0:
		die()
	else:
		invincible_timer.start()
		start_blinking()
	
func die() -> void:
	LevelManager.player_died()

func start_blinking() -> void:
	if blink_tween and blink_tween.is_running():
		blink_tween.kill()  # Stop any existing tween to avoid conflicts

	blink_tween = create_tween()  # Create a fresh tween
	blink_tween.set_loops()  # Loop until stopped
	blink_tween.tween_property(player, "modulate", Color("ffffff96"), 0.1).set_trans(Tween.TRANS_LINEAR)
	blink_tween.tween_property(player, "modulate", Color("ffffff"), 0.1).set_trans(Tween.TRANS_LINEAR)


func _on_invincible_timer_timeout() -> void:
	if blink_tween:
		blink_tween.kill()  # Properly stop and remove the tween
	player.modulate = Color("ffffff")  # Reset to normal
