extends Node

var fullscreen : bool = true : set = _set_fullscreen
var intro_completed : bool = false

var screenshake_active : bool = true
var camera_rotation_active : bool = true
var aim_following_active : bool = true

var enemies_killed : int = 0
var diamonds : int = 0
var gears : int = 0


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	set_process(false)


func _set_fullscreen(value : bool) -> void:
	fullscreen = value
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func lerp_factor(speed : float, delta : float) -> float:
	return 1 - pow(0.5, delta * speed)
