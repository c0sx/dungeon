extends Node3D

@onready var right_hand = $right_hand

func pick_item(item: Node3D):
	self.right_hand.pick_item(item)
