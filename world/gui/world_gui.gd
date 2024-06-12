extends Control

@onready var hands = $MarginContainer/HandsContainer

func _on_player_torch_picked():
	self.hands.set_right_hand()
	
