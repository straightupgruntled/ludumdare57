extends Node

var fullscreen : bool = false
var intro_completed : bool = false

var time_scale : float = 1.0
var target_time_scale : float = 1.0
var enemies_killed : int = 0


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	set_process(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_fullscreen"):
		fullscreen = !fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _process(delta):
	var time_scale_difference = abs(time_scale - target_time_scale)
	time_scale = lerpf(time_scale, target_time_scale, lerp_factor(10.0, delta))
	if time_scale_difference < 0.01:
		time_scale = target_time_scale
		set_process(false)


func lerp_factor(speed : float, delta : float) -> float:
	return 1 - pow(0.5, delta * speed)


func game_reset() -> void:
	set_time_scale(1.0)


func set_time_scale(new_time_scale : float) -> void:
	target_time_scale = new_time_scale
	set_process(true)
