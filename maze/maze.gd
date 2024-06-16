extends Node3D

@onready var grid_map: GridMap = $GridMap
@onready var camera: Camera3D = $Camera3D

@export var map_width: int = 150
@export var map_height: int = 150
@export var map_border_size: int = 2
@export var rooms_amount: int = 20
@export var min_width_of_room: int = 4
@export var max_width_of_room: int = 10
@export var min_heigth_of_room: int = 4
@export var max_heigth_of_room: int = 10
@export var range_between_rooms: int = 4
@export var iterations: int = 1000
@export var corridor_max_length: int = 20

const WAIT_TIME = 0

var rooms: Array[Room] = []
var map_rect: Rect2i

func _ready():
	map_rect = Rect2i(0, 0, map_width, map_height)
	
func generate():
	_clear_all()
	_set_camera_position()
	_draw_border()
	
	_build_rooms()
	await _draw_rooms()
	
	await _fill_corridors()
	
func _clear_all():
	var used = grid_map.get_used_cells()
	var item_id = grid_map.INVALID_CELL_ITEM
	
	for u in used:
		grid_map.set_cell_item(u, item_id)
		
	rooms = []
	
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
		

func _build_rooms():
	var iteration = 0

	while rooms.size() < rooms_amount and iteration < iterations:
		var room = _build_room()
	
		var is_intersects = _check_intersections(room, rooms)
		if not is_intersects:
			rooms.append(room)
				
		iteration += 1
			
func _build_room() -> Room: 
	var rng = RandomNumberGenerator.new()
	
	var width = rng.randi_range(min_width_of_room, max_width_of_room)
	var height = rng.randi_range(min_heigth_of_room, max_heigth_of_room)
	
	var position_x = rng.randf_range(map_border_size, map_width - width - map_border_size)
	var position_z = rng.randi_range(map_border_size, map_height - height - map_border_size)
	var position = Vector3i(position_x, 0, position_z)
	
	var room = Room.new(position, width, height)
	
	return room	

func _check_intersections(room: Room, rooms: Array[Room]) -> bool: 
	var current_room_rect = room.get_rect_2i()
	var expanded_current_room = current_room_rect.grow(range_between_rooms)
	
	return rooms.any(func (one: Room):
		var room_rect = one.get_rect_2i()
		
		return room_rect.intersects(expanded_current_room)
	)
	
func _draw_rooms():
	for room in rooms:
		_draw_room(room)

func _draw_room(room: Room):
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	var position = room.position
	var width = room.width
	var height = room.heigth
	
	for w in width:
		var x = position.x + w
		
		for h in height:
			var z = position.z + h
			
			var cell_position = Vector3i(x, 0, z)
			grid_map.set_cell_item(cell_position, item_id)

func _fill_corridors():
	for x in range(1, map_width):
		for y in range(1, map_height):
			var position = Vector3i(x, 0, y)
			var is_allowed = _is_allowed_for_path(position)
			
			if is_allowed:
				await _fill_corridor(position)
	
func _is_allowed_for_path(position: Vector3i) -> bool:
	var directions = [position, position + Vector3i.LEFT, position + Vector3i.RIGHT, position + Vector3i.FORWARD, position + Vector3i.BACK]
	
	return directions.all(func (direction):
		var cell = grid_map.get_cell_item(direction)
		
		return cell == grid_map.INVALID_CELL_ITEM	
	)

func _fill_corridor(position: Vector3i):
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	
	var positions: Array[Vector3i] = []
	await _visit_point(position, Vector3i.ZERO, item_id, positions)
	
	while positions.size() > 0:
		var position_index = randi() % positions.size()
		var current_position = positions[position_index]
		var last_position = positions.pop_back()
		
		if position_index < positions.size():
			positions[position_index] = last_position
			
		var directions = [Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT, Vector3i.FORWARD]
		directions.sort_custom(func(a, b):
			return randi() % 2 == 0	
		)
		
		while directions.size() > 0:
			var direction_index = randi() % directions.size()
			var direction = directions.pop_at(direction_index)
			
			current_position = await _visit_point(current_position, direction, item_id, positions)
		
func _visit_point(position: Vector3i, direction: Vector3i, item_id: int, positions: Array[Vector3i]) -> Vector3i: 
	var is_allowed = true
	var pos = position
	var current_length = 0
	
	while is_allowed and current_length < corridor_max_length:
		var current_pos = pos + direction
		var points = _get_points_for_direction(current_pos, direction)
		
		is_allowed = points.all(func (point):
			var cell = grid_map.get_cell_item(point)
			
			return cell == grid_map.INVALID_CELL_ITEM
		)
		
		if is_allowed:
			grid_map.set_cell_item(current_pos, item_id)
			positions.append(current_pos)
			
			await get_tree().create_timer(WAIT_TIME).timeout
			pos = current_pos
		
		current_length += 1
	
	return pos
	
func _get_points_for_direction(position: Vector3i, direction: Vector3i) -> Array[Vector3i]:
	var next_position = position + direction
	
	if direction == Vector3i.FORWARD or direction == Vector3i.BACK:
		return [
			position, # current
			position + Vector3i.RIGHT, # left
			position + Vector3i.LEFT, # right
			next_position,
			next_position + Vector3i.RIGHT,
			next_position + Vector3i.LEFT
		]
	
	return [
		position, 
		next_position, 
		position + Vector3i.FORWARD,
		next_position + Vector3i.FORWARD,
		position + Vector3i.BACK,
		next_position + Vector3i.BACK
	]
