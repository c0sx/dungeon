class_name RoomsRenderer

var _grid_map: GridMap

func _init(grid_map: GridMap):
	_grid_map = grid_map

func render(rooms: Array[Room]):
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for room in rooms:
		var position = room.get_position()
		var width = room.get_width()
		var height = room.get_height()
		
		for w in width:
			var x = position.x + w
			
			for h in height:
				var z = position.z + h
				var cell_position = Vector3i(x, 0, z)
				
				_grid_map.set_cell_item(cell_position, item_id)
		
