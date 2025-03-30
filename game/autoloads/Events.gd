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


#checkpoint
@warning_ignore("unused_signal")
signal new_active_checkpoint
