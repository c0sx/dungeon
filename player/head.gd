extends Node3D

@onready var forward = $ray_cast_forward
@onready var backward = $ray_cast_backward
@onready var left = $ray_cast_left
@onready var right = $ray_cast_right
@onready var camera = $Camera3D

@export var pick_distance = 2;

func is_forward_colliding() -> bool:
	var is_colliding = self.forward.is_colliding()
	
	return is_colliding
	
func is_backward_colliding() -> bool:
	var is_colliding = self.backward.is_colliding()
	
	return is_colliding

func is_left_colliding() -> bool:
	var is_colliding = self.left.is_colliding()
	
	return is_colliding
	
func is_right_colliding() -> bool:
	var is_colliding = self.right.is_colliding()
	
	return is_colliding

func find_pickable_item(event: InputEventMouseButton) -> Dictionary:
	var space_state = get_world_3d().direct_space_state

	var mouse_position = event.position
	var origin = camera.project_ray_origin(mouse_position)
	var end = origin + camera.project_ray_normal(mouse_position) * pick_distance
	var collision_mask = 0b010
	var query = PhysicsRayQueryParameters3D.create(origin, end, collision_mask)
	
	var result = space_state.intersect_ray(query)
	
	return result
