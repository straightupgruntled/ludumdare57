extends CanvasLayer

signal transition_complete

var current_target_scene : String
var music_pitch : float = 0.85 : set = _set_music_pitch

@onready var animation_player = $AnimationPlayer
@onready var music = $Music


func _ready():
	music.pitch_scale = music_pitch


func _physics_process(delta):
	if music.pitch_scale != music_pitch:
		music.pitch_scale = move_toward(music.pitch_scale, music_pitch, 0.01)
		if music.pitch_scale == music_pitch:
			set_physics_process(false)


func transition_to_file_scene(target_scene : String) -> void:
	animation_player.play("fade_out_scene")
	current_target_scene = target_scene


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out_scene":
		if current_target_scene:
			await get_tree().create_timer(.25).timeout
			get_tree().paused = false
			get_tree().change_scene_to_file(current_target_scene)
			animation_player.play("fade_into_scene")
	elif anim_name == "fade_into_scene":
		transition_complete.emit()


func start_music() -> void:
	if !music.playing:
		music.play()


func stop_music() -> void:
	music.stop()


func is_music_playing() -> bool:
	return music.playing


func _set_music_pitch(value : float) -> void:
	music_pitch = value
	set_physics_process(true)
