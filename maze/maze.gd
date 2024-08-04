class_name Maze
extends Node3D

@onready var grid_map: GridMap = $GridMap

@export_subgroup("map")
@export var map_width: int = 150
@export var map_height: int = 150

@export_subgroup("rooms")
@export var rooms_iterations: int = 1000
@export var rooms_amount: int = 20
@export var rooms_min_size: int = 4
@export var rooms_max_size: int = 10
@export var rooms_range_between: int = 4

@export_subgroup("passageway")
@export var passageway_min_length: int = 5

var _rooms_generator: RoomsGenerator
var _rooms_renderer: RoomsRenderer
var _passageways_generator: PassagewaysGenerator
var _passageways_renderer: PassagewaysRenderer
var _connectors_generator: ConnectorsGenerator
var _connectors_renderer: ConnectorsRenderer

func _ready():
	_rooms_generator = RoomsGenerator.new()
	_rooms_renderer = RoomsRenderer.new(grid_map)
	_passageways_generator = PassagewaysGenerator.new()
	_passageways_renderer = PassagewaysRenderer.new(grid_map)
	_connectors_generator = ConnectorsGenerator.new()
	_connectors_renderer = ConnectorsRenderer.new(grid_map)

func get_map_width() -> int:
	return map_width

func get_map_height() -> int:
	return map_height

func generate():
	_clear_all()
	
	# generation
	var map = Map.new(map_width, map_height)
	var rooms = await _rooms_generator.generate(map, rooms_amount, rooms_min_size, rooms_max_size, rooms_range_between, rooms_iterations)
	var passageways = await _passageways_generator.generate(map, passageway_min_length)
	var connectors = await _connectors_generator.generate(map)
	
	# rendering
	await _rooms_renderer.render(rooms)
	await _passageways_renderer.render(passageways)
	await _connectors_renderer.render(connectors)
	
	# await _join_regions(map)

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

