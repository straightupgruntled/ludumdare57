class_name PauseMenu
extends Control

signal menu_closed

@export_file() var main_menu_file_scene : String
@export var can_manually_open : bool = true

@onready var menu_options = $Panel2/MenuOptions
@onready var graphics_button = $Panel2/MenuOptions/GraphicsButton
@onready var sound_button = $Panel2/MenuOptions/SoundButton
@onready var controls_button = $Panel2/MenuOptions/ControlsButton

@onready var sound_settings_menu = $Panel2/SoundSettings
@onready var master_slider = $Panel2/SoundSettings/MasterSlider
@onready var music_slider = $Panel2/SoundSettings/MusicSlider
@onready var sfx_slider = $Panel2/SoundSettings/SFXSlider
@onready var dialogue_slider = $Panel2/SoundSettings/DialogueSlider


@onready var graphics_settings_menu = $Panel2/GraphicsSettings
@onready var fullscreen_checkbox = $Panel2/GraphicsSettings/HBoxContainer/FullscreenCheckbox
@onready var camera_rotation_checkbox = $Panel2/GraphicsSettings/HBoxContainer2/CameraRotationCheckbox
@onready var aim_following_checkbox = $Panel2/GraphicsSettings/HBoxContainer3/AimFollowingCheckbox
@onready var screenshake_checkbox = $Panel2/GraphicsSettings/HBoxContainer4/ScreenshakeCheckbox

var active_menu : UIMenu
var audio_settings
var graphics_settings

func _ready():
	audio_settings = ConfigFileHandler.load_audio_settings()
	
	AudioServer.set_bus_volume_linear(0, audio_settings.master_volume)
	master_slider.value = AudioServer.get_bus_volume_linear(0)
	AudioServer.set_bus_volume_linear(1, audio_settings.music_volume)
	music_slider.value = AudioServer.get_bus_volume_linear(1)
	AudioServer.set_bus_volume_linear(2, audio_settings.sfx_volume)
	sfx_slider.value = AudioServer.get_bus_volume_linear(2)
	AudioServer.set_bus_volume_linear(3, audio_settings.dialogue_volume)
	dialogue_slider.value = AudioServer.get_bus_volume_linear(3)
	
	graphics_settings = ConfigFileHandler.load_graphics_settings()
	fullscreen_checkbox.button_pressed = graphics_settings.fullscreen
	camera_rotation_checkbox.button_pressed = graphics_settings.camera_rotation
	aim_following_checkbox.button_pressed = graphics_settings.aim_following
	screenshake_checkbox.button_pressed = graphics_settings.screenshake


func _input(event):
	if event.is_action_pressed("exit_menu") and visible:
		if active_menu:
			for child in active_menu.get_children():
				child.release_focus()
			active_menu.close()
			active_menu = null
			menu_options.open()
			return
		else:
			menu_options.close()
			get_tree().paused = false
			visible = get_tree().paused
			menu_closed.emit()
			return
	if event.is_action_pressed("pause"):
		if active_menu:
			for child in active_menu.get_children():
				child.release_focus()
			active_menu.close()
			active_menu = null
			menu_options.open()
		else:
			if visible:
				menu_options.close()
				get_tree().paused = false
				visible = get_tree().paused
				menu_closed.emit()
			elif can_manually_open:
				menu_options.open()
				get_tree().paused = true
				visible = get_tree().paused


func toggle_menu() -> void:
	if active_menu:
		active_menu.close()
		active_menu = null
		menu_options.open()
	else:
		if visible:
			get_tree().paused = false
			visible = get_tree().paused
			menu_options.close()
			menu_closed.emit()
		else:
			get_tree().paused = true
			visible = get_tree().paused
			menu_options.open()


func _on_graphics_button_pressed():
	active_menu = graphics_settings_menu
	menu_options.close()
	active_menu.open()


func _on_sound_button_pressed():
	active_menu = sound_settings_menu
	menu_options.close()
	active_menu.open()


func _on_controls_button_pressed():
	pass # Replace with function body.


func _on_master_slider_value_changed(value):
	var target_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(target_bus, value)
	ConfigFileHandler.save_audio_setting("master_volume", value)


func _on_music_slider_value_changed(value):
	var target_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(target_bus, value)
	ConfigFileHandler.save_audio_setting("music_volume", value)


func _on_sfx_slider_value_changed(value):
	var target_bus = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(target_bus, value)
	ConfigFileHandler.save_audio_setting("sfx_volume", value)


func _on_dialogue_slider_value_changed(value):
	var target_bus = AudioServer.get_bus_index("Dialogue")
	AudioServer.set_bus_volume_linear(target_bus, value)
	ConfigFileHandler.save_audio_setting("dialogue_volume", value)


func _on_exit_button_pressed():
	hide()
	TransitionManager.transition_to_file_scene(main_menu_file_scene)


func _on_resume_button_pressed():
	toggle_menu()


func _on_fullscreen_checkbox_toggled(toggled_on):
	Global.fullscreen = toggled_on
	ConfigFileHandler.save_graphics_setting("fullscreen", toggled_on)


func _on_camera_rotation_checkbox_toggled(toggled_on):
	Global.camera_rotation_active = toggled_on
	ConfigFileHandler.save_graphics_setting("camera_rotation", toggled_on)


func _on_aim_following_checkbox_toggled(toggled_on):
	Global.aim_following_active = toggled_on
	ConfigFileHandler.save_graphics_setting("aim_following", toggled_on)


func _on_screenshake_checkbox_toggled(toggled_on):
	Global.screenshake_active = toggled_on
	ConfigFileHandler.save_graphics_setting("screenshake", toggled_on)
