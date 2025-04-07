extends Control

@export_file() var target_scene : String


func _ready():
	$AnimationPlayer.play("win_animation")


func _on_animation_player_animation_finished(anim_name):
	TransitionManager.transition_to_file_scene(target_scene)
