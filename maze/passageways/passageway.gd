class_name Passageway

var _points: Array[Vector3i]

func append(point: Vector3i):
	_points.append(point)

func size() -> int:
	return _points.size()

func get_points() -> Array[Vector3i]:
	return _points

func includes(point: Vector3i) -> bool:
	return _points.has(point)
