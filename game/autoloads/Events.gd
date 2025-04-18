extends Node
#global Events bus

@warning_ignore("unused_signal")
signal player_attacked(direction : Vector2)

@warning_ignore("unused_signal")
signal player_hp_changed(new_hp : float)

@warning_ignore("unused_signal")
signal camera_freeze_axis(axis : Enums.AXIS)

@warning_ignore("unused_signal")
signal camera_stop_freeze_axis()


#levels
@warning_ignore("unused_signal")
signal load_level()
signal new_level_loaded() #for when a new level has been loaded


#juice
@warning_ignore("unused_signal")
signal player_hit()

#checkpoint
@warning_ignore("unused_signal")
signal new_active_checkpoint

#camera signals
@warning_ignore("unused_signal")
signal combat_camera_shake
@warning_ignore("unused_signal")
signal freeze_frame(duration: float, slow_motion_scale: float)
@warning_ignore("unused_signal")
signal zoom_camera(zoom_amount : float, duration : float)


signal fade_to_black(duration:float)
signal immobilize_player()
