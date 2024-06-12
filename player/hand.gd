extends Node3D

func pick_item(collider):
	collider.reparent(self);
