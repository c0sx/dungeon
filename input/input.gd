extends Node3D

signal on_moving_forward(event: InputEventKey)
signal on_moving_backward(event: InputEventKey)
signal on_strafe_left(event: InputEventKey)
signal on_strafe_right(event: InputEventKey)
signal on_rotation_left(event: InputEventKey)
signal on_rotation_right(event: InputEventKey)
signal on_left_mouse_pressed(event: InputEventMouseButton)

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	pass

func _input(event):
	if event.is_action("exit"):
		get_tree().quit(0)
		
	if event is InputEventKey:
		if event.is_action_pressed("forward"):
			emit_signal("on_moving_forward", event)
		elif event.is_action_pressed("backward"):
			emit_signal("on_moving_backward", event)
		elif event.is_action_pressed("left"):
			emit_signal("on_strafe_left", event)
		elif event.is_action_pressed("right"):
			emit_signal("on_strafe_right", event)
		elif event.is_action_pressed("rotate_left"):
			emit_signal("on_rotation_left", event)
		elif event.is_action_pressed("rotate_right"):
			emit_signal("on_rotation_right", event)
			
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("on_left_mouse_pressed", event)
