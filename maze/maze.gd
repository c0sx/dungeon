extends Node3D

@onready var grid_map: GridMap = $GridMap
@onready var camera: Camera3D = $Camera3D

@export var map_width: int = 150
@export var map_height: int = 150
@export var map_border_size: int = 2

@export var rooms_iterations: int = 1000
@export var rooms_amount: int = 20
@export var min_size_of_room: int = 4
@export var max_size_of_room: int = 10
@export var range_between_rooms: int = 4

@export var corridor_min_length: int = 5
@export var width_of_corridor_collision: int = 2 

const WAIT_TIME = 0

var rooms: Array[Room] = []
var x_border: Vector2i
var y_border: Vector2i

func generate():
	_clear_all()
	_set_camera_position()
	_draw_border()
	
	_build_rooms()
	_draw_rooms()
	
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
	
	x_border = Vector2i(0, map_width - 1)
	y_border = Vector2i(0, map_height - 1)

func _build_rooms():
	var iteration = 0

	while rooms.size() < rooms_amount and iteration < rooms_iterations:
		var room = _build_room()
	
		var is_intersects = _check_intersections(room, rooms)
		if not is_intersects:
			rooms.append(room)
				
		iteration += 1
			
func _build_room() -> Room: 
	var rng = RandomNumberGenerator.new()
	
	var width = rng.randi_range(min_size_of_room, max_size_of_room)
	var height = rng.randi_range(min_size_of_room, max_size_of_room)
	
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
	for x in range(map_border_size + 1, map_width - map_border_size):
		for y in range(map_border_size + 1, map_height - map_border_size):
			var point = Vector3i(x, 0, y)
			var is_allowed = _is_allowed_for_path(point)
			
			if is_allowed:
				# fill passageway
				await _fill_corridor(point)
				# drop short corridors
	
	print("corridors are filled")
	
func _is_allowed_for_path(position: Vector3i) -> bool:
	var directions: Array[Vector3i] = []
	
	for w in range(0, width_of_corridor_collision):
		var left_position = position + Vector3i.LEFT * w
		var right_position = position + Vector3i.RIGHT * w
		
		for h in range(0, width_of_corridor_collision):
			var top_left_position = left_position + Vector3i.FORWARD * h
			var top_right_position = right_position + Vector3i.FORWARD * h
			var bottom_left_position = left_position + Vector3i.BACK * h
			var bottom_right_position = right_position + Vector3i.BACK * h
			
			if _point_in_rect(top_left_position):
				directions.append(top_left_position)
				
			if _point_in_rect(top_right_position):
				directions.append(top_right_position)
				
			if _point_in_rect(bottom_left_position):
				directions.append(bottom_left_position)
				
			if _point_in_rect(bottom_right_position):
				directions.append(bottom_right_position)
			
	return directions.all(func (direction):
		var cell = grid_map.get_cell_item(direction)
		
		return cell == grid_map.INVALID_CELL_ITEM
	)

# https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
func _fill_corridor(position: Vector3i):
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	var positions: Array[Vector3i] = [position]
	var current_corridor_length = 0
	var current_direction: Vector3i = Vector3i.ZERO
	
	while positions.size() > 0:
		var position_index = positions.size() - 1
		var current_position = positions[position_index]
		
		grid_map.set_cell_item(current_position, item_id)
		await get_tree().create_timer(WAIT_TIME).timeout
		
		var unchecked_directions = _get_unvisited_neighbors(current_position)
		
		if unchecked_directions.size() == 0:
			positions.remove_at(position_index)
		else:
			var result = _get_current_direction(current_corridor_length, current_direction, unchecked_directions)
			
			current_direction = result[0]
			current_corridor_length = result[1]
				
			positions.append(current_position + current_direction)

func _get_unvisited_neighbors(position: Vector3i) -> Array[Vector3i]:
	var directions: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT, Vector3i.FORWARD]
	
	return directions.filter(func (direction):
		var points = _get_collision_constraints(position, direction)
		
		return points.all(func (point): 
			var cell = grid_map.get_cell_item(point)
			
			return cell == grid_map.INVALID_CELL_ITEM
		)
	)

func _get_current_direction(current_length: int, current_direction: Vector3i, unchecked_directions: Array[Vector3i]):
	if unchecked_directions.has(current_direction) and current_length < corridor_min_length:
		return [current_direction, current_length + 1]
	
	unchecked_directions.shuffle()
	var new_direction = unchecked_directions.pop_back()
	
	return [new_direction, 0]

# draw collision object for point by direction
# for example
# 
# point: [0;0]
# direction: Vector3i.RIGHT
#
#			| width_of_corridor_collision: 2
#			|
#   		| [3;0;3] [4;0;3]
# [2;0;2] 	| [3;0;2] [4;0;2]
#   		| [3;0;1] [4;0;1]
func _get_collision_constraints(position: Vector3i, direction: Vector3i) -> Array[Vector3i]:
	var start_of_collision = position + direction
	var result: Array[Vector3i] = []
	
	for w in range(0, width_of_corridor_collision):
		var middle_position = start_of_collision + direction * w
		result.append(middle_position)
		
		for h in range(1, width_of_corridor_collision):
			var directions = _get_collision_directions(direction);
			
			for collision_direction in directions:
				var collision_position = middle_position + collision_direction * h
				
				if _point_in_rect(collision_position):
					result.append(collision_position)
			
	return result

func _get_collision_directions(direction: Vector3i) -> Array[Vector3i]:
	if direction == Vector3i.FORWARD or direction == Vector3i.BACK:
		return [Vector3i.RIGHT, Vector3i.LEFT]
		
	return [Vector3i.FORWARD, Vector3i.BACK]

func _point_in_rect(point: Vector3i) -> bool:
	return point.x > x_border.x and point.x < x_border.y and point.z > y_border.x and point.z < y_border.y
