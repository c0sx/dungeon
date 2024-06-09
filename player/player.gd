extends CharacterBody3D

@onready var head = $head

@export var moving_time = 0.25
@export var rotation_time = 0.2
@export var moving_distance = 1.5

var tween: Tween

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		
func _input(event):
	if event.is_action("exit"):
		get_tree().quit(0)
		
	if event is InputEventKey:
		self._handle_input(event)
	
func _handle_input(event: InputEventKey):
	if event.echo:
		return;
		
	if event.is_action_pressed("rotate_left"):
		_rotate_left()
	elif event.is_action_pressed("rotate_right"):
		_rotate_right()
		
	if event.is_action_pressed("forward"):
		_move_forward()
	elif event.is_action_pressed("backward"):
		_move_backward()
	elif event.is_action_pressed("left"):
		_strafe_left()
	elif event.is_action_pressed("right"):
		_strafe_right()
		
func _move_forward(): 
	if head.is_forward_colliding():
		return
	
	var direction = Vector3.FORWARD
	_move(direction)

func _move_backward():
	if head.is_backward_colliding():
		return
		
	var direction = Vector3.BACK
	_move(direction)
	
func _strafe_left():
	if head.is_left_colliding():
		return
		
	var direction = Vector3.LEFT
	_move(direction)
	
func _strafe_right():
	if head.is_right_colliding():
		return
		
	var direction = Vector3.RIGHT
	_move(direction)

func _move(direction: Vector3):
	if tween is Tween:
		if tween.is_running():
			return;
			
	tween = create_tween()
	
	var offset = direction * self.moving_distance
	var translated = transform.translated_local(offset)
	
	tween.tween_property(self, "transform", translated, self.moving_time)

func _rotate_left():
	var direction = deg_to_rad(90)
	
	_rotate(direction)

func _rotate_right():
	var direction = deg_to_rad(-90)
	
	_rotate(direction)
	
func _rotate(direction: float):
	if tween is Tween:
		if tween.is_running():
			return;
			
	tween = create_tween()
	
	var rotated = transform.basis.rotated(Vector3.UP, direction)
	
	tween.tween_property(self, "transform:basis", rotated, self.rotation_time)

