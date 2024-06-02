extends CharacterBody3D

@onready var head = $head

@export var speed = 5.0
@export var mouse_sensitivity = 0.2
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action("exit"):
		get_tree().quit(0)
		
	if event is InputEventMouseMotion:
		self._looking(event.relative)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	_moving(delta)


func _moving(delta: float):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _looking(relative: Vector2):
	var x = relative.x * -1
	var rad_x = deg_to_rad(x * mouse_sensitivity)
	rotate_y(rad_x)
	
	var y = relative.y * -1;
	var rad_y = deg_to_rad(y * mouse_sensitivity)
	head.rotate_x(rad_y)	
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
