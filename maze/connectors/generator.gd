class_name ConnectorsGenerator

var _tree: SceneTree
var _grid_map: GridMap

func _init(tree, grid_map: GridMap):
	_tree = tree
	_grid_map = grid_map

func draw(map: Map, rooms: Array[Room]):
	for y in range(map.get_min_y(), map.get_max_y()):
		for x in range(map.get_min_x(), map.get_max_x()):
			var item_id = _grid_map.mesh_library.find_item_by_name("connector")
			var point = Vector3i(x, 0, y)
			
			if _grid_map.get_cell_item(point) == _grid_map.INVALID_CELL_ITEM:
				_handle_connector(point, rooms)
				await _tree.create_timer(0).timeout

func _handle_connector(point: Vector3i, rooms: Array[Room]):
	var item_id = _grid_map.mesh_library.find_item_by_name("connector")
	
	await _handle_horizontal_connector(point, rooms)
	await _handle_vertical_connector(point, rooms)
		
func _handle_horizontal_connector(point: Vector3i, rooms: Array[Room]):
	var item_id = _grid_map.mesh_library.find_item_by_name("connector")
		
	var left_point = point + Vector3i.LEFT
	var right_point = point + Vector3i.RIGHT
	var left_cell = _grid_map.get_cell_item(left_point)	
	var right_cell = _grid_map.get_cell_item(right_point)
	
	if [left_cell, right_cell].has(_grid_map.INVALID_CELL_ITEM):
		return
	
	var left_is_room = _point_connected_to_room(left_point, rooms)
	var right_is_room = _point_connected_to_room(right_point, rooms)
	
	if (left_is_room != right_is_room) and left_is_room == true or right_is_room == true:
		_grid_map.set_cell_item(point, item_id)	
		
func _handle_vertical_connector(point: Vector3i, rooms: Array[Room]):
	var item_id = _grid_map.mesh_library.find_item_by_name("connector")
		
	var top_point = point + Vector3i.FORWARD
	var bottom_point = point + Vector3i.BACK
	var top_cell = _grid_map.get_cell_item(top_point)	
	var bottom_cell = _grid_map.get_cell_item(bottom_point)
	
	if [top_cell, bottom_cell].has(_grid_map.INVALID_CELL_ITEM):
		return
		
	var top_is_room = _point_connected_to_room(top_point, rooms)
	var bottom_is_room = _point_connected_to_room(bottom_point, rooms)
	
	if (top_is_room != bottom_is_room) and top_is_room == true or bottom_is_room == true:
		_grid_map.set_cell_item(point, item_id)	

func _point_connected_to_room(point: Vector3i, rooms: Array[Room]) -> bool:
	return rooms.any(func (room):
		return room.has_point(point)	
	)
