class_name Map

var _width: int
var _heigth: int

var _rooms: Array[Room] = []
var _passageways: Array[Passageway] = []
var _connectors: Array[Connector] = []
var _cells: Dictionary

func _init(width: int, height: int):
	_width = width
	_heigth = height
	
	_cells = Dictionary()

func get_iterator() -> MapIterator:
	var start = Vector3i(0, 0, 0)
	var end = Vector3i(_width - 1, 0, _heigth - 1)
	
	return MapIterator.new(start, end)

func get_rect() -> Rect2i:
	return Rect2i(0, 0, _width, _heigth)

func get_min_x() -> int:
	return 0

func get_min_y() -> int:
	return 0

func get_max_x() -> int:
	return _width - 1
	
func get_max_y() -> int:
	return _heigth - 1
	
func get_width() -> int:
	return _width

func get_height() -> int:
	return _heigth
	
func includes(point: Vector3i) -> bool:
	return point.x >= get_min_x() and point.x <= get_max_x() and point.z >= get_min_y() and point.z <= get_max_y()

func append_rooms(rooms: Array[Room]):
	for room in rooms:
		append_room(room)
		
func append_room(room: Room):
	_rooms.append(room)
	
	var points = room.get_points()
	
	for point in points:
		_cells[point] = room
		
func get_rooms() -> Array[Room]:
	return _rooms
	
func get_connectors() -> Array[Connector]:
	return _connectors
		
func append_passageways(passageways: Array[Passageway]):
	for passageway in passageways:
		append_passageway(passageway)

func append_passageway(passageway: Passageway):
	var points = passageway.get_points()
	
	for point in points:
		_cells[point] = passageway
		
func append_connectors(connectors: Array[Connector]):
	for connector in connectors:
		append_connector(connector)
		
func append_connector(connector: Connector):
	_connectors.append(connector)
	
	var point = connector.get_point()
	
	_cells[point] = connector

func remove_connector(connector: Connector):
	var index = _connectors.find(connector)
	
	if index == -1:
		return
	
	_connectors.remove_at(index)
	_cells.erase(connector.get_point())
	
func get_region(point: Vector3i):
	if _cells.has(point):
		return _cells.get(point)
		
	return null

func remove_room(room: Room):
	var index = _rooms.find(room)
	
	if index == -1:
		return;
		
	_rooms.remove_at(index)
	_cells.erase(room.get_points())
