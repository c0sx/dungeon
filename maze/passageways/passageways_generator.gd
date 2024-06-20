class_name PassagewaysGenerator

var _tree: SceneTree
var _grid_map: GridMap

func _init(tree: SceneTree, grid_map: GridMap):
	_tree = tree
	_grid_map = grid_map
	
func draw(map: Map, min_length: int):
	for y in range(map.get_min_y(), map.get_max_y()):
		for x in range(map.get_min_x(), map.get_max_x()):
			var point = Vector3i(x, 0, y)
			var is_allowed = _is_allowed_for_path(map, point)
			
			if is_allowed:
				await _fill_passageway(map, point, min_length)

func _is_allowed_for_path(map: Map, position: Vector3i) -> bool:
	var directions: Array[Vector3i] = []
	
	for w in range(0, 2):
		var left_position = position + Vector3i.LEFT * w
		var right_position = position + Vector3i.RIGHT * w
		directions.append(left_position)
		directions.append(right_position)
		
		for h in range(1, 2):
			var top_left_position = left_position + Vector3i.FORWARD * h
			var top_right_position = right_position + Vector3i.FORWARD * h
			var bottom_left_position = left_position + Vector3i.BACK * h
			var bottom_right_position = right_position + Vector3i.BACK * h
			
			directions.append(top_left_position)
			directions.append(top_right_position)
			directions.append(bottom_left_position)
			directions.append(bottom_right_position)
	
	var filtered = directions.filter(func (point):
		return map.has_point(point)
	)
	
	return filtered.all(func (direction):
		return _grid_map.get_cell_item(direction) == _grid_map.INVALID_CELL_ITEM
	)
	
# https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
func _fill_passageway(map: Map, position: Vector3i, min_length: int):
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	var positions: Array[Vector3i] = [position]
	var current_corridor_length = 0
	var current_direction: Vector3i = Vector3i.ZERO
	
	while positions.size() > 0:
		var position_index = positions.size() - 1
		var current_position = positions[position_index]
		_grid_map.set_cell_item(current_position, item_id)
		#await _tree.create_timer(0).timeout
		
		var unchecked_directions = await _get_unvisited_neighbors(map, current_position)
		
		if unchecked_directions.size() == 0:
			positions.remove_at(position_index)
		else:
			var result = _get_current_direction(current_corridor_length, current_direction, unchecked_directions, min_length)
			
			current_direction = result[0]
			current_corridor_length = result[1]
				
			positions.append(current_position + current_direction)

func _get_unvisited_neighbors(map: Map, position: Vector3i) -> Array[Vector3i]:
	var directions: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT, Vector3i.FORWARD]
	var filtered: Array[Vector3i] = []
	
	for direction in directions:
		var collision_rect = _get_collision_constraints(map, position, direction)
		
		## region
		## render collisions for tests
		#var collisions = collision_rect.filter(func (one):
			#return _grid_map.get_cell_item(one) == _grid_map.INVALID_CELL_ITEM	
		#)
		#
		#for point in collisions:
			#var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
			#_grid_map.set_cell_item(point, item_id)
			#
		#await _tree.create_timer(0).timeout
		#
		#for point in collisions:
			#_grid_map.set_cell_item(point, _grid_map.INVALID_CELL_ITEM)
			#
		#await _tree.create_timer(0).timeout
		### endregion
			
		var is_allowed = collision_rect.size() > 0 and collision_rect.all(func (point): 
			return _grid_map.get_cell_item(point) == _grid_map.INVALID_CELL_ITEM
		)
		
		if is_allowed:
			filtered.append(direction)
			
	return filtered

func _get_current_direction(current_length: int, current_direction: Vector3i, unchecked_directions: Array[Vector3i], min_lenght: int):
	if unchecked_directions.has(current_direction) and current_length < min_lenght:
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
#   		| [3;0;3] [4;0;3]
# [2;0;2] 	| [3;0;2] [4;0;2]
#   		| [3;0;1] [4;0;1]
func _get_collision_constraints(map: Map, position: Vector3i, direction: Vector3i) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var directions = _get_collision_directions(direction);
	
	for w in range(1, 3):
		var middle_point = position + direction * w
		result.append(middle_point)
		
		for h in range(1, 2):
			for side_direction in directions:
				var side_point = middle_point + side_direction * h
				result.append(side_point)
				
	var filtered = result.filter(func (point):
		return map.has_point(point)	
	)
	
	return filtered
					
func _get_collision_directions(direction: Vector3i) -> Array[Vector3i]:
	if direction == Vector3i.FORWARD or direction == Vector3i.BACK:
		return [Vector3i.RIGHT, Vector3i.LEFT]
		
	return [Vector3i.FORWARD, Vector3i.BACK]
