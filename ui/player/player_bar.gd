extends Control

@onready var left_hand = $HBoxContainer/LeftHandMarginContainer/HandBar
@onready var right_hand = $HBoxContainer/RightHandMarginContainer/HandBar

func set_item():
	right_hand.set_item()
	
