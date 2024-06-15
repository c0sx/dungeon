extends Control

@onready var item_texture = $Panel/ItemTexture

func set_item():
	# put resource as argument
	var resource = load("res://torch/icons/torch-icon-48.png")
	self.item_texture.texture = resource
