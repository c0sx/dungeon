class_name Room

var _position: Vector3i
var _width: int
var _heigth: int

func _init(position: Vector3i, width: int, height: int):
	_position = position
	_width = width
	_heigth = height

func get_rect_2i() -> Rect2i:
	return Rect2i(
		Vector2i(_position.x, _position.z),
		Vector2i(_width, _heigth)
	)

func get_position() -> Vector3i:
	return _position
	
func get_width() -> int:
	return _width
	
func get_height() -> int:
	return _heigth

func has_point(point: Vector3i) -> bool:
	var rect = get_rect_2i()

	return rect.has_point(Vector2i(point.x, point.z))

func get_points() -> Array[Vector3i]:
	var points: Array[Vector3i] = []
	var rect = get_rect_2i()
	
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			points.append(Vector3i(x, 0, y))
			
	return points

func is_adjacent_connector(connector: Connector) -> bool:
	var points = get_points()
	
	return points.any(func (point):
		return connector.is_adjacent(point)	
	)
