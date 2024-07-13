class_name MapGenerator

var _grid_map: GridMap

func _init(grid_map):
	_grid_map = grid_map
	
func draw(width: int, height: int, border: int) -> Map:
	var map = Map.new(width, height, border)
				
	return map

