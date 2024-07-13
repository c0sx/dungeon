class_name ConnectorsGenerator

var _tree: SceneTree
var _grid_map: GridMap

func _init(tree, grid_map: GridMap):
	_tree = tree
	_grid_map = grid_map

func draw(map: Map, rooms: Array[Room], passageways: Array[Passageway]) -> Array[Connector]:
	var connectors: Array[Connector] = []
	
	for y in range(map.get_min_y(), map.get_max_y()):
		for x in range(map.get_min_x(), map.get_max_x()):
			var point = Vector3i(x, 0, y)
			
			if _grid_map.get_cell_item(point) == _grid_map.INVALID_CELL_ITEM:
				var connector = _handle_connector(map, point)
				
				if connector != null:
					connectors.append(connector)
	
	return connectors

func _handle_connector(map: Map, point: Vector3i) -> Connector:
	var item_id = _grid_map.mesh_library.find_item_by_name("connector")
	
	var horizontal = [Vector3i.LEFT, Vector3i.RIGHT]
	var vertical = [Vector3i.FORWARD, Vector3i.BACK]
	var sides = [horizontal, vertical]
	
	for side in sides:
		var point_a = point + side[0]
		var point_b = point + side[1]
		
		var cell_a = _grid_map.get_cell_item(point_a)
		var cell_b = _grid_map.get_cell_item(point_b)
		var is_not_allowed = [cell_a, cell_b].any(func (cell):
			return [_grid_map.INVALID_CELL_ITEM, item_id].has(cell)
		)
		
		if is_not_allowed:
			continue
		
		var region_a = map.get_region(point_a)
		var region_b = map.get_region(point_b)
	
		if region_a != region_b:
			_grid_map.set_cell_item(point, item_id)
			var connector = Connector.new(point)
			
			return connector

	return null
