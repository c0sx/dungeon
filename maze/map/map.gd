class_name Map

var _width: int
var _heigth: int
var _border: int

var _rooms: Array[Room]
var _passageways: Array[Passageway]
var _cells: Dictionary

func _init(width: int, height: int, border: int):
	_width = width
	_heigth = height
	_border = border
	
	_cells = Dictionary()

func get_rect() -> Rect2i:
	return Rect2i(_border, _border, _width - _border, _heigth - _border)

func get_min_x() -> int:
	return _border

func get_min_y() -> int:
	return _border

func get_max_x() -> int:
	return _width - _border - 1
	
func get_max_y() -> int:
	return _heigth - _border - 1
	
func get_width() -> int:
	return _width

func get_height() -> int:
	return _heigth
	
func has_point(point: Vector3i) -> bool:
	return point.x >= get_min_x() and point.x <= get_max_x() and point.z >= get_min_y() and point.z <= get_max_y()

func append_room(room: Room):
	var points = room.get_points()
	
	for point in points:
		_cells[point] = room

func append_passageway(passageway: Passageway):
	var points = passageway.get_points()
	
	for point in points:
		_cells[point] = passageway
		
func get_region(point: Vector3i):
	if _cells.has(point):
		return _cells.get(point)
		
	return null
