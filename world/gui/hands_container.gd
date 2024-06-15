extends HBoxContainer

@onready var right_hand: TextureRect = $Panel/RightHand

func _ready():
	right_hand.visible = false;

func set_right_hand():
	self.right_hand.visible = true
	
	var resource = load("res://torch/torch-icon-48.png")
	self.right_hand.texture = resource
