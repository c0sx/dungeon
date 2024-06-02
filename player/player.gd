extends CharacterBody3D

@onready var head = $head

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	move_and_slide()
	
func _input(event):
	if event.is_action("exit"):
		get_tree().quit(0)
		
	if event is InputEventKey:
		self._tile_moving(event)
	
func _tile_moving(event: InputEventKey):
	if event.echo:
		return;
		
	var distance = 1.5

	if event.is_action_pressed("forward") and not head.is_forward_colliding():
		translate(Vector3(0, 0, -distance))
	elif event.is_action_pressed("backward") and not head.is_backward_colliditon():
		translate(Vector3(0, 0, distance))
	elif event.is_action_pressed("left") and not head.is_left_colliding():
		translate(Vector3(-distance, 0, 0))
	elif event.is_action_pressed("right") and not head.is_right_colliding():
		translate(Vector3(distance, 0, 0))
	elif event.is_action_pressed("rotate_left"):
		rotate_y(deg_to_rad(90))
	elif event.is_action_pressed("rotate_right"):
		rotate_y(deg_to_rad(-90))
