class_name RoomsGenerator

var _grid_map: GridMap

func _init(grid_map: GridMap):
	_grid_map = grid_map

func draw(map: Map, amount: int, min_size: int, max_size: int, range_between_rooms: int, iterations: int) -> Array[Room]:
	var rooms = _build_rooms(map, amount, min_size, max_size, range_between_rooms, iterations)
	_draw_rooms(rooms)
	
	return rooms

func _build_rooms(map: Map, amount: int, min_size: int, max_size: int, range: int, iterations: int) -> Array[Room]:
	var rooms: Array[Room] = []
	var iteration = 0

	while rooms.size() < amount and iteration < iterations:
		var room = _build_room(map, min_size, max_size)
	
		var is_intersects = _check_intersections(room, rooms, range)
		if not is_intersects:
			rooms.append(room)
				
		iteration += 1
	
	return rooms

func _build_room(map: Map, min_size: int, max_size: int) -> Room: 
	var rng = RandomNumberGenerator.new()
	
	var width = rng.randi_range(min_size, max_size)
	var height = rng.randi_range(min_size, max_size)
	
	var rect = map.get_rect()
	var position_x = rng.randf_range(rect.position.x, rect.size.x - width)
	var position_z = rng.randi_range(rect.position.y, rect.size.y - height)
	var position = Vector3i(position_x, 0, position_z)
	
	var room = Room.new(position, width, height)
	
	return room	

func _check_intersections(room: Room, rooms: Array[Room], range: int) -> bool: 
	var current_room_rect = room.get_rect_2i()
	var expanded_current_room = current_room_rect.grow(range)
	
	return rooms.any(func (one: Room):
		var room_rect = one.get_rect_2i()
		
		return room_rect.intersects(expanded_current_room)
	)

func _draw_rooms(rooms: Array[Room]):
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for room in rooms:
		var position = room.position
		var width = room.width
		var height = room.heigth
		
		for w in width:
			var x = position.x + w
			
			for h in height:
				var z = position.z + h
				var cell_position = Vector3i(x, 0, z)
				
				_grid_map.set_cell_item(cell_position, item_id)
		
