extends BTAction

func _tick(_delta: float) -> Status:
	if agent.is_stunned():
		return SUCCESS #if enemy is stunned return Success, since selector will return and keep playing this
	return FAILURE #if enemy is not stunnet return failure, since selector will continue
