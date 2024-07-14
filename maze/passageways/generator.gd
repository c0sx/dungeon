class_name PassagewaysGenerator

var _tree: SceneTree
var _grid_map: GridMap

func _init(tree: SceneTree, grid_map: GridMap):
	_tree = tree
	_grid_map = grid_map
	
func draw(map: Map, min_length: int):
	var passageways: Array[Passageway] = []
	
	for point in map.get_iterator():
		var is_allowed = _is_allowed_for_path(map, point)
		if not is_allowed:
			continue
			
		var passageway = await _fill_passageway(map, point, min_length)
		if passageway.size() > 1:
			passageways.append(passageway)
	
	return passageways
	
func _is_allowed_for_path(map: Map, position: Vector3i) -> bool:
	var directions: Array[Vector3i] = []
	var start_area = PassagewayStartPointArea.new(position, 2)
	
	var area_points = start_area.get_points()
	var filtered = area_points.filter(func (point):
		return map.has_point(point)
	)
	
	return filtered.all(func (point):
		var item = _grid_map.get_cell_item(point)
		var region = map.get_region(point)
		
		# todo: stopped here
		return region == null
		
		return _grid_map.get_cell_item(point) == _grid_map.INVALID_CELL_ITEM
	)
	
# https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
func _fill_passageway(map: Map, position: Vector3i, min_length: int) -> Passageway:
	var passageway = Passageway.new()
	
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	var positions: Array[Vector3i] = [position]
	var current_corridor_length = 0
	var current_direction: Vector3i = Vector3i.ZERO
	
	while positions.size() > 0:
		var position_index = positions.size() - 1
		var current_position = positions[position_index]
		_grid_map.set_cell_item(current_position, item_id)
		passageway.append(current_position)
		
		var unchecked_directions = await _get_unvisited_neighbors(map, current_position)
		
		if unchecked_directions.size() == 0:
			positions.remove_at(position_index)
		else:
			var result = _get_current_direction(current_corridor_length, current_direction, unchecked_directions, min_length)
			
			current_direction = result[0]
			current_corridor_length = result[1]
				
			positions.append(current_position + current_direction)
	
	return passageway

func _get_unvisited_neighbors(map: Map, position: Vector3i) -> Array[Vector3i]:
	var directions: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.BACK, Vector3i.LEFT, Vector3i.FORWARD]
	var filtered: Array[Vector3i] = []
	
	for direction in directions:
		var collision_rect = _get_collision_constraints(map, position, direction)
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
