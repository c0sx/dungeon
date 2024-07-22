class_name RoomsRenderer

var _grid_map: GridMap

func _init(grid_map: GridMap):
	_grid_map = grid_map

func render(rooms: Array[Room]):
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for room in rooms:
		var points = room.get_points()
		
		for point in points:
			_grid_map.set_cell_item(point, item_id)
		
