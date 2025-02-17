extends BTAction

func _tick(_delta: float) -> Status:
	if agent.recently_hit():
		return SUCCESS
	else:
		return FAILURE
