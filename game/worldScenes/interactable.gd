extends Node
class_name Interactable #uses OnOffObject for enabling

@export var is_enabled : bool = false
var triggers : Array[OnOffObject] # set in parent

signal enabled_changed(state: bool)

func initialize() -> void:
	for trigger : OnOffObject in triggers:
		trigger.toggled.connect(_on_trigger_toggled)
	_update_is_enabled()
	
func _on_trigger_toggled(_state: bool) -> void:
	_update_is_enabled()

func _update_is_enabled() -> void:
	if triggers.is_empty():
		print("this interactable is empty, will never enable")
		return
	
	var all_enabled = triggers.all(func(trigger : OnOffObject): return trigger.is_on)
	if is_enabled != all_enabled:
		is_enabled = all_enabled
		emit_signal("enabled_changed", is_enabled)
