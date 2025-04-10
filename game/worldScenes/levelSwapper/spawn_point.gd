extends Marker2D
class_name SpawnPoint

@export var spawn_id: String

func _ready():
	add_to_group("spawn_points")
