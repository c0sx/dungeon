class_name Room

var position: Vector3i
var width: int
var heigth: int

func _init(position: Vector3i, width: int, height: int):
	self.position = position
	self.width = width
	self.heigth = height

func get_rect_2i() -> Rect2i:
	return Rect2i(
		Vector2i(position.x, position.z),
		Vector2i(width, heigth)
	)
