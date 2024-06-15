extends Control

@onready var player_bar = $PlayerBar

func _on_player_torch_picked():
	player_bar.set_item();
