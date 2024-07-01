class_name Region

var _points: Array[Vector3i] 

func _init():
	_points = []
	
func get_points() -> Array[Vector3i]:
	return _points
	
func append(points: Array[Vector3i]): 
	for point in points:
		_points.append(point)

# if any point adjacent with points of other region
func is_adjacent(other: Region) -> bool:
	var sides = [Vector3i.LEFT, Vector3i.RIGHT, Vector3i.FORWARD, Vector3i.BACK]
	var other_points = other.get_points()
	
	for p in _points:
		for o in other_points:
			for s in sides:
				if p + s == o:
					return true
	
	return false
