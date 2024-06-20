class_name RoomsGenerator

var _grid_map: GridMap
var _rooms: Array[Room] = []
var _iterations: int
var _min_size: int
var _max_size: int
var _amount: int
var _range_between_rooms: int

func _init(grid_map: GridMap, amount: int, min_size: int, max_size: int, range_between_rooms: int, iterations: int):
	_grid_map = grid_map
	_amount = amount
	_min_size = min_size
	_max_size = max_size
	_iterations = iterations
	_range_between_rooms = range_between_rooms

func clear_all(): 
	_rooms.clear()

func draw(map: Map):
	_build_rooms(map)
	_draw_rooms()

func _build_rooms(map: Map):
	var iteration = 0

	while _rooms.size() < _amount and iteration < _iterations:
		var room = _build_room(map)
	
		var is_intersects = _check_intersections(room, _rooms)
		if not is_intersects:
			_rooms.append(room)
				
		iteration += 1

func _build_room(map: Map) -> Room: 
	var rng = RandomNumberGenerator.new()
	
	var width = rng.randi_range(_min_size, _max_size)
	var height = rng.randi_range(_min_size, _max_size)
	
	var rect = map.get_rect()
	var position_x = rng.randf_range(rect.position.x, rect.size.x - width)
	var position_z = rng.randi_range(rect.position.y, rect.size.y - height)
	var position = Vector3i(position_x, 0, position_z)
	
	var room = Room.new(position, width, height)
	
	return room	

func _check_intersections(room: Room, rooms: Array[Room]) -> bool: 
	var current_room_rect = room.get_rect_2i()
	var expanded_current_room = current_room_rect.grow(_range_between_rooms)
	
	return rooms.any(func (one: Room):
		var room_rect = one.get_rect_2i()
		
		return room_rect.intersects(expanded_current_room)
	)

func _draw_rooms():
	for room in _rooms:
		_draw_room(room)
		

func _draw_room(room: Room):
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	var position = room.position
	var width = room.width
	var height = room.heigth
	
	for w in width:
		var x = position.x + w
		
		for h in height:
			var z = position.z + h
			
			var cell_position = Vector3i(x, 0, z)
			_grid_map.set_cell_item(cell_position, item_id)
