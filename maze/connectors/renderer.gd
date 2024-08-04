class_name ConnectorsRenderer

var _grid_map: GridMap

func _init(grid_map: GridMap):
	_grid_map = grid_map
	
func render(connectors: Array[Connector]):
	var item_id = _grid_map.mesh_library.find_item_by_name("connector")
	
	for connector in connectors:
		_grid_map.set_cell_item(connector.get_point(), item_id)
