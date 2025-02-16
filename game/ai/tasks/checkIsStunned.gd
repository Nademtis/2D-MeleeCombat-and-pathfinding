extends BTAction

func _tick(delta: float) -> Status:
	if agent.is_stunned():
		return SUCCESS
	return FAILURE
