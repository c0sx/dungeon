class_name PassagewaysRenderer

var _grid_map: GridMap

func _init(grid_map: GridMap):
	_grid_map = grid_map
	
func render(passageways: Array[Passageway]):
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for passageway in passageways:
		var points = passageway.get_points()
		
		for point in points:
			_grid_map.set_cell_item(point, item_id)
