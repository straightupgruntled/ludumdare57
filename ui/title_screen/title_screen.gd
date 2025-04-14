extends Control

@export_file() var level_scene_file : String
@export_file() var stage_scene_file : String

var time : float = 0.0
var can_start : bool = false
var entering : bool = false

@onready var title = $Title
@onready var ld_logo = $LDLogo
@onready var background_sprite = $Background/BackgroundSprite
@onready var cover = $Background/Cover
@onready var cart_player_sprite = $Background/BackgroundSprite/CartPlayerSprite
@onready var pause_menu = $PauseMenu
@onready var menu_options = $MenuOptions
@onready var start_button = $MenuOptions/StartButton
@onready var settings_button = $MenuOptions/SettingsButton


func _ready():
	TransitionManager.music_pitch = 0.85
	EventBus.intro_finished.connect(intro_completed)
	if Global.intro_completed:
		can_start = true
		TransitionManager.start_music()
	else:
		get_tree().paused = true
		TransitionManager.stop_music()


func _process(delta):
	time += delta
	title.scale = Vector2.ONE * (1.0 + sin(time * 4.0) * 0.02)
	title.rotation_degrees = sin((time + PI) * 2.0)
	cart_player_sprite.rotation_degrees = 1.5 * sin(time * 2.5)
	cart_player_sprite.scale = Vector2.ONE * (1.0 + sin(time * 4.0) * 0.02)
	if entering:
		title.modulate.a = lerpf(title.modulate.a, 0.0, delta * 16.0)
		cover.modulate.a = lerpf(cover.modulate.a, 0.0, delta * 1.0)
		ld_logo.modulate.a = lerpf(ld_logo.modulate.a, 0.0, delta * 16.0)
		background_sprite.scale = background_sprite.scale.move_toward(Vector2.ONE * 1.5, 0.5 * delta)


func intro_completed() -> void:
	await get_tree().process_frame
	can_start = true


func start_game() -> void:
	if can_start:
		menu_options.is_open = false
		entering = true
		can_start = false
		await get_tree().create_timer(1.0).timeout
		if ConfigFileHandler.new_game_launch:
			TransitionManager.transition_to_file_scene(level_scene_file)
		else:
			TransitionManager.transition_to_file_scene(stage_scene_file)


func _on_exit_button_pressed():
	get_tree().quit()


func _on_start_button_pressed():
	start_game()


func _on_settings_button_pressed():
	pause_menu.toggle_menu()
	menu_options.close()


func _on_pause_menu_menu_closed():
	menu_options.open()


func _on_intro_overlay_finished():
	TransitionManager.start_music()
	get_tree().paused = false
