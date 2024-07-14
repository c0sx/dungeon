extends Node3D

@export var maze: Maze
@export var camera: Camera3D

func _ready():
	_set_camera_position()
	
	await maze.generate()
	
func _set_camera_position():
	var map_width = maze.get_map_width()
	var map_height = maze.get_map_height()
	var x = map_width / 2
	var z = map_height / 2

	camera.position = Vector3(x, camera.position.y, z)
