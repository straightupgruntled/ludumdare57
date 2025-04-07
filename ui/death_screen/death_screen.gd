extends Control

@onready var animation_player = $AnimationPlayer



func trigger_game_over() -> void:
	animation_player.play("start_game_over")
