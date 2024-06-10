extends Node3D

@onready var forward = $ray_cast_forward
@onready var backward = $ray_cast_backward
@onready var left = $ray_cast_left
@onready var right = $ray_cast_right

func is_forward_colliding():
	var is_colliding = forward.is_colliding()
	
	print("is colliding", is_colliding)
	
	return is_colliding
	
func is_backward_colliding():
	var is_colliding = backward.is_colliding()
	
	return is_colliding

func is_left_colliding():
	var is_colliding = left.is_colliding()
	
	return is_colliding
	
func is_right_colliding():
	var is_colliding = right.is_colliding()
	
	return is_colliding
