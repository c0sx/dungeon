class_name MapIterator

var _start: Vector3i
var _end: Vector3i
var _current: Vector3i

func _init(start: Vector3i, end: Vector3i):
	_start = start
	_end = end
	
	_current = start

func should_continue():
	var is_x_continue = _current.x < _end.x
	var is_y_continue = _current.y < _end.y
	var is_z_continue = _current.z < _end.z
	
	return is_x_continue or is_y_continue or is_z_continue

func _iter_init(arg):
	_current = _start
	
	return should_continue()

func _iter_next(arg):
	var x = _current.x
	var y = _current.y
	var z = _current.z
	
	if x < _end.x:
		x += 1
	elif y < _end.y:
		y += 1
		x = 0
	elif z < _end.z:
		z += 1
		y = 0
		x = 0
		
	_current = Vector3i(x, y, z)
	
	return should_continue()
	
func _iter_get(arg):
	return _current
