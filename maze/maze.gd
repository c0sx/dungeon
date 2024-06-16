extends Node3D

@onready var grid_map: GridMap = $GridMap
@onready var camera: Camera3D = $Camera3D

@export var map_width: int = 500
@export var map_height: int = 300
@export var rooms_amount: int = 20
@export var min_width_of_room: int = 4
@export var max_width_of_room: int = 10
@export var min_heigth_of_room: int = 4
@export var max_heigth_of_room: int = 10
@export var range_between_rooms: int = 4
@export var retries = 1000

var rooms: Array[Room] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	generate()
	
func generate():
	_clear_all()
	_set_camera_position()
	_draw_border()
	
	_build_rooms(retries)
	_draw_rooms()
	
func _clear_all():
	var used = grid_map.get_used_cells()
	var item_id = grid_map.INVALID_CELL_ITEM
	
	for u in used:
		grid_map.set_cell_item(u, item_id)
		
	rooms = []
	
func _set_camera_position():
	var x = map_width / 2
	var z = map_height / 2
	
	camera.position = Vector3(x, camera.position.y, z)

func _draw_border():
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	
	for w in map_width:
		for h in map_height:
			if w == 0 or w == map_width - 1 or h == 0 or h == map_height - 1:
				grid_map.set_cell_item(Vector3i(w, 0, h), item_id)
		

func _build_rooms(retries: int):
	var iteration = 0

	while rooms.size() < rooms_amount and iteration < retries:
		var room = _build_room()
	
		var is_intersects = _check_intersections(room, rooms)
		if not is_intersects:
			rooms.append(room)
				
		iteration += 1
			
func _build_room() -> Room: 
	var rng = RandomNumberGenerator.new()
	
	var width = rng.randi_range(min_width_of_room, max_width_of_room)
	var height = rng.randi_range(min_heigth_of_room, max_heigth_of_room)
	
	var position_x = rng.randf_range(1, map_width - width - 1)
	var position_z = rng.randi_range(1, map_height - height - 1)
	var position = Vector3i(position_x, 0, position_z)
	
	var room = Room.new(position, width, height)
	
	return room	

func _check_intersections(room: Room, rooms: Array[Room]) -> bool: 
	var current_room_rect = room.get_rect_2i()
	var expanded_current_room = current_room_rect.grow(range_between_rooms)
	
	return rooms.any(func (one: Room):
		var room_rect = one.get_rect_2i()
		
		return room_rect.intersects(expanded_current_room)
	)
	
func _draw_rooms():
	for room in rooms:
		_draw_room(room)

func _draw_room(room: Room):
	var item_id = grid_map.mesh_library.find_item_by_name("floor-opened")
	var position = room.position
	var width = room.width
	var height = room.heigth
	
	for w in width:
		var x = position.x + w
		
		for h in height:
			var z = position.z + h
			
			var cell_position = Vector3i(x, 0, z)
			grid_map.set_cell_item(cell_position, item_id)
