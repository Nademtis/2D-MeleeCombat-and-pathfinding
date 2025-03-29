extends Node
#autoload LevelManager

var active_level : Level
#const LEVEL_1 = preload("res://levels/level_1.tscn")
var main: Node2D

func _ready() -> void:
	Events.connect("load_level", load_level)
	main = get_tree().get_root().get_node("main")
	
	#load level 1 if there is no active level
	if active_level == null:
		var new_level = Level.new("res://levels/level_1.tscn", "level_1")
		load_level(new_level)
	
func load_level(new_level : Level)->void:
	if active_level:
		for child in main.get_children():
			child.queue_free()
	
	await get_tree().process_frame  # Ensure cleanup before adding a new level
	
	var packed_new_level_scene : PackedScene = load(new_level.level_path)
	var instansiated_level = packed_new_level_scene.instantiate()
	instansiated_level.set_name(new_level.level_name)
	
	if main:
		main.add_child(instansiated_level)
		active_level = new_level # set new active level

func player_died() -> void:
	# Reload the level from the last active checkpoint
	var active_checkpoint: Checkpoint = CheckpointManager.get_active_checkpoint()
	if active_checkpoint:
		load_level_from_checkpoint(active_checkpoint)
	else:
		# If no checkpoint exists, just restart the current level
		load_level(active_level)
	

func load_level_from_checkpoint(checkpoint: Checkpoint) -> void:
	await load_level(get_level_from_level_name(checkpoint.level_name))
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("moved player to checkpoint")
		player.global_position = checkpoint.position

func get_active_level() -> Level:
	return active_level
	
func get_active_level_name() -> String:
	return active_level.level_name

func get_level_from_level_name(level_name : String) -> Level:
	var level_path = "res://levels/" + level_name + ".tscn"
	return Level.new(level_path, level_name)
	
