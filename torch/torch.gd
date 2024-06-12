extends StaticBody3D

@onready var flame = $Flame

func picked(): 
	_hide_flame()

func _hide_flame():
	#flame.emitting = false
	pass;
