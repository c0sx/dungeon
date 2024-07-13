extends Node

@export var maze: Maze
@export var spawn_point: GridMap

func _ready():
	maze.generate()
	pass
