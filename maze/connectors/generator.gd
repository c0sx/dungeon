class_name ConnectorsGenerator

func generate(map: Map) -> Array[Connector]:
	var connectors: Array[Connector] = []
	
	for point in map.get_iterator():
		var is_empty = map.get_region(point) == null
		
		if is_empty:
			var connector = _handle_connector(map, point)
				
			if connector != null:
				connectors.append(connector)
	
	map.append_connectors(connectors)
	return connectors

func _handle_connector(map: Map, point: Vector3i) -> Connector:
	var horizontal = [Vector3i.LEFT, Vector3i.RIGHT]
	var vertical = [Vector3i.FORWARD, Vector3i.BACK]
	var sides = [horizontal, vertical]
	
	for side in sides:
		var point_a = point + side[0]
		var point_b = point + side[1]
		
		var region_a = map.get_region(point_a)
		var region_b = map.get_region(point_b)
		var is_not_allowed = [region_a, region_b].any(func (cell):
			return cell == null || cell is Connector
		)
		
		if is_not_allowed:
			continue
		
		if region_a != region_b:
			var connector = Connector.new(point)
			
			return connector

	return null
