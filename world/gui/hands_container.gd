extends HBoxContainer

@onready var right_hand: TextureRect = $RightHand;

func _ready():
	right_hand.visible = false;

func set_right_hand():
	self.right_hand.visible = true
	
	var resource = load("res://torch/icon.jpg")
	self.right_hand.texture = resource
