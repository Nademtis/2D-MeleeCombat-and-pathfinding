@tool
extends Node

@export var toggle_visibility: bool = false : set = _set_visibility

func _set_visibility(value: bool) -> void:
	toggle_visibility = value
	for child in get_children():
		if child is CanvasItem:  # Only affects nodes that have a visible property
			child.visible = toggle_visibility
