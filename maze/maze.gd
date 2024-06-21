extends Node3D

@onready var grid_map: GridMap = $GridMap
@onready var camera: Camera3D = $Camera3D

@export_subgroup("map")
@export var map_width: int = 150
@export var map_height: int = 150
@export var map_border: int = 2

@export_subgroup("rooms")
@export var rooms_iterations: int = 1000
@export var rooms_amount: int = 20
@export var rooms_min_size: int = 4
@export var rooms_max_size: int = 10
@export var rooms_range_between: int = 4

@export_subgroup("passageway")
@export var passageway_width: int = 1
@export var passageway_min_length: int = 5

var _map_generator: MapGenerator
var _rooms_generator: RoomsGenerator
var _passageways_generator: PassagewaysGenerator
var _connectors_generator: ConnectorsGenerator

func _ready():
	_map_generator = MapGenerator.new(grid_map)
	_rooms_generator = RoomsGenerator.new(grid_map)
	_passageways_generator = PassagewaysGenerator.new(get_tree(), grid_map)
	_connectors_generator = ConnectorsGenerator.new(get_tree(), grid_map)

func generate():
	_clear_all()
	_set_camera_position()
	
	var map = await _map_generator.draw(map_width, map_height, map_border)
	var rooms = await _rooms_generator.draw(map, rooms_amount, rooms_min_size, rooms_max_size, rooms_range_between, rooms_iterations)
	await _passageways_generator.draw(map, passageway_min_length)
	await _connectors_generator.draw(map, rooms)
	
func _clear_all():
	var used = grid_map.get_used_cells()
	var item_id = grid_map.INVALID_CELL_ITEM
	
	for u in used:
		grid_map.set_cell_item(u, item_id)
	
func _set_camera_position():
	var x = map_width / 2
	var z = map_height / 2
	
	camera.position = Vector3(x, camera.position.y, z)

func _draw_border():
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for w in map_width:
		for h in map_height:
			if w == 0 or w == map_width - 1 or h == 0 or h == map_height - 1:
				grid_map.set_cell_item(Vector3i(w, 0, h), item_id)
