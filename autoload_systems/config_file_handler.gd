extends Node

const SETTING_FILE_PATH = "user://settings.ini"
var config = ConfigFile.new()
var new_game_launch : bool = true


func _ready():
	if !FileAccess.file_exists(SETTING_FILE_PATH):
		print("CONFIG FILE CREATE")
		# Audio Settings Setup #
		config.set_value("Audio", "master_volume", 0.7)
		config.set_value("Audio", "music_volume", 0.7)
		config.set_value("Audio", "sfx_volume", 0.7)
		config.set_value("Audio", "dialogue_volume", 0.7)
		# Graphics Settings Setup #
		config.set_value("Graphics", "fullscreen", false)
		config.set_value("Graphics", "camera_rotation", true)
		config.set_value("Graphics", "aim_following", true)
		config.set_value("Graphics", "screenshake", true)
		# Save New Settings Config#
		config.save(SETTING_FILE_PATH)
		new_game_launch = true
	else:
		# Load Settings Config#
		config.load(SETTING_FILE_PATH)
		new_game_launch = false
	var audio_settings = load_audio_settings()
	AudioServer.set_bus_volume_linear(0, audio_settings.master_volume)
	AudioServer.set_bus_volume_linear(1, audio_settings.music_volume)
	AudioServer.set_bus_volume_linear(2, audio_settings.sfx_volume)
	AudioServer.set_bus_volume_linear(3, audio_settings.dialogue_volume)
	var graphics_settings = load_graphics_settings()
	Global.fullscreen = graphics_settings.fullscreen
	Global.camera_rotation_active = graphics_settings.camera_rotation
	Global.aim_following_active = graphics_settings.aim_following
	Global.screenshake_active = graphics_settings.screenshake


func save_audio_setting(key : String, value):
	config.set_value("Audio", key, value)
	config.save(SETTING_FILE_PATH)


func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("Audio"):
		audio_settings[key] = config.get_value("Audio", key)
	return audio_settings


func save_graphics_setting(key : String, value):
	config.set_value("Graphics", key, value)
	config.save(SETTING_FILE_PATH)


func load_graphics_settings():
	var graphics_settings = {}
	for key in config.get_section_keys("Graphics"):
		graphics_settings[key] = config.get_value("Graphics", key)
	return graphics_settings
