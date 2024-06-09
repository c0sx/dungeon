extends CharacterBody3D

@onready var head = $head

@export var moving_time = 0.25
@export var rotation_time = 0.2
@export var moving_distance = 1.5

signal on_moving_forward_command
signal on_moving_backward_command
signal on_strafe_left_command
signal on_strafe_right_command
signal on_rotation_left
signal on_rotation_right

var tween: Tween

func move_forward(event: InputEventKey): 
	if not _is_input_allowed(event) or head.is_forward_colliding():
		return
	
	var direction = Vector3.FORWARD
	_move(direction)

func move_backward(event: InputEventKey):
	if not _is_input_allowed(event) or head.is_backward_colliding():
		return
		
	var direction = Vector3.BACK
	_move(direction)
	
func strafe_left(event: InputEventKey):
	if not _is_input_allowed(event) or head.is_left_colliding():
		return
		
	var direction = Vector3.LEFT
	_move(direction)
	
func strafe_right(event: InputEventKey):
	if not _is_input_allowed(event) or head.is_right_colliding():
		return
		
	var direction = Vector3.RIGHT
	_move(direction)
	
func rotate_left(event: InputEventKey):
	if not _is_input_allowed(event):
		return
		
	var direction = deg_to_rad(90)
	
	_rotate(direction)

func rotate_right(event: InputEventKey):
	if not _is_input_allowed(event):
		return
		
	var direction = deg_to_rad(-90)
	
	_rotate(direction)
	
func _is_input_allowed(event: InputEventKey):
	return not event.echo

func _move(direction: Vector3):
	if tween is Tween:
		if tween.is_running():
			return;
			
	tween = create_tween()
	
	var offset = direction * self.moving_distance
	var translated = transform.translated_local(offset)
	
	tween.tween_property(self, "transform", translated, self.moving_time)
	
func _rotate(direction: float):
	if tween is Tween:
		if tween.is_running():
			return;
			
	tween = create_tween()
	
	var rotated = transform.basis.rotated(Vector3.UP, direction)
	
	tween.tween_property(self, "transform:basis", rotated, self.rotation_time)
