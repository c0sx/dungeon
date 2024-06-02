extends Node3D

@onready var forward = $ray_cast_forward
@onready var backward = $ray_cast_backward
@onready var left = $ray_cast_left
@onready var right = $ray_cast_right

func is_forward_colliding():
	return forward.is_colliding()
	
func is_backward_colliditon():
	return backward.is_colliding()

func is_left_colliding():
	return left.is_colliding()
	
func is_right_colliding():
	return right.is_colliding()
