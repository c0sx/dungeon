class_name Map

var _width: int
var _heigth: int
var _border: int

func _init(width: int, height: int, border: int):
	_width = width
	_heigth = height
	_border = border

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
