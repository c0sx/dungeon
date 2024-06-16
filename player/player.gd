extends CharacterBody3D

@onready var head = $head
@onready var hands = $hands

@export var moving_time = 0.25
@export var rotation_time = 0.2
@export var moving_distance = 1.5

signal torch_picked

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var tween: Tween

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()

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

func push_button(event: InputEventMouseButton):
	var item = self.head.find_button(event);
	
	var collider = null
	if item.has("collider"):
		collider = item.get("collider")
		
	if collider == null:
		return
		
	print(collider)
	collider.queue_free()
	
func pick_up_item(event: InputEventMouseButton):
	var item = self.head.find_pickable_item(event);
	
	var collider = null
	if item.has("collider"):
		collider = item.get("collider")
	
	if collider == null:
		return
		
	self.hands.pick_item(collider);
	emit_signal("torch_picked")
		
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
