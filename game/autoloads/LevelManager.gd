extends Node
# Autoload: LevelManager

var active_level_scene: PackedScene
var active_level_name: String
var level_container: Node
var player_spawn_position : Vector2

var main: Node2D

func _ready() -> void:
	Events.connect("load_level", load_level)
	main = get_tree().get_root().get_node("main")
	level_container = main.get_node("LevelContainer")

	if not active_level_scene:
		var default_level = load("res://levels/level_0.tscn") as PackedScene
		await load_level(default_level, "default_spawn") # replace with actual spawn_id

func load_level(level_scene: PackedScene, spawn_id: String) -> void:
	#print("level_scene ", level_scene)
	#print("id ", spawn_id)
	# Remove old level
	for child in level_container.get_children():
		child.queue_free()
	await get_tree().process_frame

	# Instantiate new level
	var new_level_instance = level_scene.instantiate()
	level_container.add_child(new_level_instance)

	# Update active references
	active_level_scene = level_scene
	active_level_name = new_level_instance.name

	# Wait until scene is ready
	await get_tree().process_frame

	if spawn_id != "checkpoint": # don't need to set player pos when checkpoint, since it is done via player died
		var spawn_point = get_spawn_point(new_level_instance, spawn_id)
		if spawn_point:
			#player_spawn_position = spawn_point.global_position # used by player in player ready()
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.global_position = spawn_point.global_position
		else:
			push_error("Spawn point '%s' not found in %s" % [spawn_id, level_scene.resource_path])

	Engine.time_scale = 1
	Events.emit_signal("new_level_loaded")

func get_spawn_point(level: Node, spawn_id: String) -> Node2D:
	for node in level.get_tree().get_nodes_in_group("spawn_points"):
		if node.has_method("get") and node.get("spawn_id") == spawn_id:
			return node
	return null

func player_died() -> void:
	Events.emit_signal("immobilize_player")
	Events.emit_signal("fade_to_black", 1)
	await get_tree().create_timer(1.5).timeout

	var checkpoint = CheckpointManager.get_active_checkpoint()
	if checkpoint:
		await load_level(load("res://levels/%s.tscn" % checkpoint.level_name), "checkpoint") # error here
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.global_position = checkpoint.position
		#player_spawn_position = checkpoint.global_position # used by player in player ready()
	else:
		await load_level(active_level_scene, "default_spawn") # fallback if no checkpoint

func get_active_level_name() -> String:
	return active_level_name
