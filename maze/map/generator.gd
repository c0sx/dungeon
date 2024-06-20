class_name MapGenerator

var _grid_map: GridMap

func _init(grid_map):
	_grid_map = grid_map
	
func draw(width: int, height: int, border: int) -> Map:
	var map = Map.new(width, height, border)
	var item_id = _grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for w in width:
		for h in height:
			if w == 0 or w == width - 1 or h == 0 or h == height - 1:
				_grid_map.set_cell_item(Vector3i(w, 0, h), item_id)
				
	return map

