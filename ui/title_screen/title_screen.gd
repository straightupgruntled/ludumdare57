extends Control

@export_file() var level_scene_file : String

@onready var title = $Title

var time : float = 0.0
var can_start : bool = false
var entering : bool = false

@onready var hint = $Hint
@onready var background_sprite = $Background/BackgroundSprite
@onready var cart_player_sprite = $Background/BackgroundSprite/CartPlayerSprite


func _ready():
	Global.intro_completed = false
	EventBus.intro_finished.connect(intro_completed)


func _input(event):
	if event.is_action_pressed("skip_intro") and can_start:
		if is_instance_valid(hint):
			hint.hide()
		TransitionManager.transition_to_file_scene(level_scene_file)
		entering = true
		can_start = false


func _process(delta):
	time += delta
	title.scale = Vector2.ONE * (1.0 + sin(time * 4.0) * 0.02)
	title.rotation_degrees = sin((time + PI) * 2.0)
	cart_player_sprite.rotation_degrees = 1.5 * sin(time * 2.5)
	cart_player_sprite.scale = Vector2.ONE * (1.0 + sin(time * 4.0) * 0.02)
	if entering:
		background_sprite.scale = background_sprite.scale.move_toward(Vector2.ONE * 1.5, 0.5 * delta)
	if InputMode.is_keyboard():
		hint.text = "ENTER TO START"
	elif InputMode.is_gamepad():
		hint.text = "X TO START"


func intro_completed() -> void:
	await get_tree().process_frame
	can_start = true


func _on_check_button_toggled(toggled_on):
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, toggled_on)
