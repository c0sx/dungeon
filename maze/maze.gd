class_name Maze
extends Node3D

@onready var grid_map: GridMap = $GridMap

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
	
	var map = await _map_generator.draw(map_width, map_height, map_border)
	var rooms = await _rooms_generator.draw(map, rooms_amount, rooms_min_size, rooms_max_size, rooms_range_between, rooms_iterations)
	map.append_rooms(rooms)
		
	var passageways = await _passageways_generator.draw(map, passageway_min_length)
	map.append_passageways(passageways)
		
	var connectors = await _connectors_generator.draw(map, rooms, passageways)
	map.append_connectors(connectors)
	
	await _join_regions(map)

func _join_regions(map: Map):
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for room in map.get_rooms():
		var region = Region.from_room(room)
		var connectors = _get_adjacent_connectors(map, region)
		var connector = _get_random_connector(connectors)
		
		grid_map.set_cell_item(connector.get_point(), item_id)
		
		for one in connectors:
			if one != connector:
				grid_map.set_cell_item(one.get_point(), grid_map.INVALID_CELL_ITEM)

func _clear_all():
	var used = grid_map.get_used_cells()
	var item_id = grid_map.INVALID_CELL_ITEM
	
	for u in used:
		grid_map.set_cell_item(u, item_id)
	
func _get_adjacent_connectors(map: Map, main_region: Region) -> Array[Connector]:
	var region_connectors: Array[Connector] = []
	var connectors = map.get_connectors()
	
	for connector in connectors:
		var region = Region.from_connector(connector)
		
		if main_region.is_adjacent(region):
			region_connectors.append(connector)
	
	return region_connectors

func _get_random_connector(connectors: Array[Connector]) -> Connector:
	var rng = RandomNumberGenerator.new()
	var index = rng.randi_range(0, connectors.size() - 1)
	var connector = connectors[index]
	
	return connector
