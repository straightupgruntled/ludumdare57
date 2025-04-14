extends Control

@export_file() var menu_scene : String

@onready var hint = $Hint
@onready var master_slider = $MasterSlider

var audio_settings
var hint_can_show : bool = false


func _ready():
	TransitionManager.start_music()
	master_slider.value = AudioServer.get_bus_volume_linear(0)
	master_slider.grab_focus()
	hint_can_show = true


func _process(delta):
	if InputMode.is_keyboard():
		hint.text = "ENTER TO CONTINUE"
	elif InputMode.is_gamepad():
		hint.text = "X TO CONTINUE"
	if Input.is_action_just_pressed("skip_intro"):
		get_tree().change_scene_to_file(menu_scene)


func _on_master_slider_value_changed(value):
	var target_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(target_bus, value)
	ConfigFileHandler.save_audio_setting("MasterVolume", value)
	if hint_can_show:
		hint.show()
