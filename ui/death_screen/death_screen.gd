extends Control

var floors_cleared : int = 0

@onready var animation_player = $AnimationPlayer
@onready var floors_cleared_text = $FloorsClearedText


func trigger_game_over() -> void:
	show()
	animation_player.play("start_game_over")
	floors_cleared_text.text = "Floors Cleared: " + str(floors_cleared)
