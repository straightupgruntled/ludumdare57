extends CanvasLayer

signal transition_complete

var current_target_scene : String

@onready var animation_player = $AnimationPlayer


func transition_to_file_scene(target_scene : String) -> void:
	animation_player.play("fade_out_scene")
	current_target_scene = target_scene


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out_scene":
		if current_target_scene:
			await get_tree().create_timer(.25).timeout
			get_tree().change_scene_to_file(current_target_scene)
			animation_player.play("fade_into_scene")
	elif anim_name == "fade_into_scene":
		transition_complete.emit()
