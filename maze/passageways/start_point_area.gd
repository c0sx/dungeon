class_name PassagewayStartPointArea

var _position: Vector3i
var _expand: int
var _cells: Array[Vector3i]

func _init(position: Vector3i, expand: int):
	_position = position
	_expand = expand
	
	_cells = _expand_point(position, expand)

func get_points() -> Array[Vector3i]:
	return _cells

func _expand_point(point: Vector3i, expand: int) -> Array[Vector3i]:
	var area: Array[Vector3i] = []
	var horizontal = [Vector3i.LEFT, Vector3i.ZERO, Vector3i.RIGHT]
	var vertical = [Vector3i.FORWARD, Vector3i.ZERO, Vector3i.BACK]
	
	for h_direction in horizontal:
		var h_point = point + h_direction
		
		for v_direction in vertical:
			var area_point = h_point + v_direction
			area.append(area_point)
		
	return area
