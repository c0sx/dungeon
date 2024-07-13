class_name Connector

var _point: Vector3i

func _init(point: Vector3i):
	_point = point

func get_point() -> Vector3i:
	return _point
	
func get_points() -> Array[Vector3i]:
	return [_point]

func is_adjacent(point: Vector3i) -> bool:
	var sides = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
	var points = sides.map(func (side):
		return _point + side	
	)
	
	return points.any(func (side):
		return side == point
	)
