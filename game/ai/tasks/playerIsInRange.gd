extends BTAction

@export var range_px : int

func _tick(_delta: float) -> Status:
	if agent.global_position.distance_to(PlayerStats.player_position) <= range_px:
		return SUCCESS
	else:
		return FAILURE
