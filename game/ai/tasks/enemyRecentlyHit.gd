extends BTAction

func _tick(delta: float) -> Status:
	if agent.recently_hit():
		return SUCCESS
	else:
		return FAILURE
