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
	map.append_rooms(rooms)
		
	var passageways = await _passageways_generator.draw(map, passageway_min_length)
	map.append_passageways(passageways)
		
	var connectors = await _connectors_generator.draw(map, rooms, passageways)
	map.append_connectors(connectors)
	
	await _set_connectors(map)
	
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

func _set_connectors(map: Map):
	var main_region = _get_main_region(map)
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	
	var iter = 0
	var iters = 2
	while iter < iters:
		iter += 1
		
		var region_connectors = _get_adjacent_connectors(map, main_region)
		var random_connector = _get_random_region_connector(region_connectors)
		
		grid_map.set_cell_item(random_connector.get_point(), item_id)
		main_region.append([random_connector.get_point()])
		
		_remove_other_adjacent_connectors(map, random_connector, region_connectors)
		
		await _render_main_region(main_region)

func _get_main_region(map: Map) -> Region:
	var rng = RandomNumberGenerator.new()

	var rooms = map.get_rooms()
	var index = rng.randi_range(0, rooms.size() - 1)
	var room = rooms[index]
	
	var region = Region.new()
	region.append(room.get_points())
	
	return region

func _get_adjacent_connectors(map: Map, main_region: Region) -> Array[Connector]:
	var region_connectors: Array[Connector] = []
	var connectors = map.get_connectors()
	
	for connector in connectors:
		var region = Region.new()
		region.append([connector.get_point()])
		
		if main_region.is_adjacent(region):
			region_connectors.append(connector)
	
	return region_connectors

func _get_random_region_connector(region_connectors: Array[Connector]) -> Connector:
	var rng = RandomNumberGenerator.new()
	var index = rng.randi_range(0, region_connectors.size() - 1)
	var connector = region_connectors[index]
	
	return connector

func _remove_other_adjacent_connectors(map: Map, connector: Connector, connectors: Array[Connector]):
	for one in connectors:
		if one == connector:
			continue
			
		grid_map.set_cell_item(one.get_point(), grid_map.INVALID_CELL_ITEM)
		map.remove_connector(one) 

func _render_main_region(region: Region):
	var item_id = grid_map.mesh_library.find_item_by_name("connector")
		
	for point in region.get_points():
		grid_map.set_cell_item(point, item_id)
		await get_tree().create_timer(0).timeout
