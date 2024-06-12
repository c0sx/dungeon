extends Node3D

func pick_item(collider: Node3D):
	collider.reparent(self)
	collider.position = Vector3.ZERO
	
	# for Torch
	collider.picked()
