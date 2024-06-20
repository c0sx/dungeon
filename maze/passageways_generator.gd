class_name PassagewaysGenerator

var _tree: SceneTree
var _grid_map: GridMap
var _collision_width: int
var _min_length: int

func _init(tree: SceneTree, grid_map: GridMap, collision_width: int, min_length: int):
	_tree = tree
	
	_grid_map = grid_map
	_collision_width = collision_width
	_min_length = min_length
	
func draw(map: Map):
	for x in range(map.get_min_x(), map.get_max_x()):
		for y in range(map.get_min_y(), map.get_max_y()):
			var point = Vector3i(x, 0, y)
			var is_allowed = _is_allowed_for_path(map, point)
			
			if is_allowed:
				await _fill_passageway(map, point)

func _is_allowed_for_path(map: Map, position: Vector3i) -> bool:
	var directions: Array[Vector3i] = []
	
	for w in range(0, _collision_width):
		var left_position = position + Vector3i.LEFT * w
		var right_position = position + Vector3i.RIGHT * w
		
		for h in range(0, _collision_width):
			var top_left_position = left_position + Vector3i.FORWARD * h
			var top_right_position = right_position + Vector3i.FORWARD * h
			var bottom_left_position = left_position + Vector3i.BACK * h
			var bottom_right_position = right_position + Vector3i.BACK * h
			
			if map.has_point(top_left_position):
				directions.append(top_left_position)
				
			if map.has_point(top_right_position):
				directions.append(top_right_position)
				
			if map.has_point(bottom_left_position):
				directions.append(bottom_left_position)
				
			if map.has_point(bottom_right_position):
				directions.append(bottom_right_position)
			
	return directions.all(func (direction):
		var cell = _grid_map.get_cell_item(direction)
		
		return cell == _grid_map.INVALID_CELL_ITEM
	)
	
# https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
func _fill_passageway(map: Map, position: Vector3i):
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	var positions: Array[Vector3i] = [position]
	var current_corridor_length = 0
	var current_direction: Vector3i = Vector3i.ZERO
	
	while positions.size() > 0:
		var position_index = positions.size() - 1
		var current_position = positions[position_index]
		
		_grid_map.set_cell_item(current_position, item_id)
		await _tree.create_timer(0).timeout
		
		var unchecked_directions = _get_unvisited_neighbors(map, current_position)
		
		if unchecked_directions.size() == 0:
			positions.remove_at(position_index)
		else:
			var result = _get_current_direction(current_corridor_length, current_direction, unchecked_directions)
			
			current_direction = result[0]
			current_corridor_length = result[1]
				
			positions.append(current_position + current_direction)

func _get_unvisited_neighbors(map: Map, position: Vector3i) -> Array[Vector3i]:
	var directions: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT, Vector3i.FORWARD]
	
	return directions.filter(func (direction):
		var points = _get_collision_constraints(map, position, direction)
		
		return points.all(func (point): 
			var cell = _grid_map.get_cell_item(point)
			
			return cell == _grid_map.INVALID_CELL_ITEM
		)
	)

func _get_current_direction(current_length: int, current_direction: Vector3i, unchecked_directions: Array[Vector3i]):
	if unchecked_directions.has(current_direction) and current_length < _min_length:
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
func _get_collision_constraints(map: Map, position: Vector3i, direction: Vector3i) -> Array[Vector3i]:
	var start_of_collision = position + direction
	var result: Array[Vector3i] = []
	
	for w in range(0, _collision_width):
		var middle_position = start_of_collision + direction * w
		result.append(middle_position)
		
		for h in range(1, _collision_width):
			var directions = _get_collision_directions(direction);
			
			for collision_direction in directions:
				var collision_position = middle_position + collision_direction * h
				
				if map.has_point(collision_position):
					result.append(collision_position)
			
	return result

func _get_collision_directions(direction: Vector3i) -> Array[Vector3i]:
	if direction == Vector3i.FORWARD or direction == Vector3i.BACK:
		return [Vector3i.RIGHT, Vector3i.LEFT]
		
	return [Vector3i.FORWARD, Vector3i.BACK]
