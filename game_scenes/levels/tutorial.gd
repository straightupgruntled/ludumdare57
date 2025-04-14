class_name TutorialLevel
extends Node2D

@onready var wall = $TutorialWalls/Wall
@onready var wall_2 = $TutorialWalls/Wall2

var combat_triggered : bool = false


@onready var groundtip_1 = $TutorialText/Groundtip1
@onready var groundtip_2 = $TutorialText/Groundtip2
@onready var groundtip_3 = $TutorialText/Groundtip3
@onready var groundtip_4 = $TutorialText/Groundtip4

@export_file() var next_level : String

@onready var floor_objects = $FloorObjects
@onready var follow_camera = $FollowCamera

@export var player : Player
@export var cart : Cart
@export var platform : Platform


func _ready():
	TransitionManager.start_music()
	if player:
		player.can_move = true
	Global.enemies_killed = 0
	EventBus.tutorial_enemies_killed.connect(wall.lower)
	EventBus.tutorial_enemies_killed.connect(wall_2.lower)
	InputMode.input_type_changed.connect(input_changed)
	input_changed()


func platform_descent_started() -> void:
	follow_camera.target_node = platform
	await get_tree().create_timer(2.0).timeout
	TransitionManager.transition_to_file_scene(next_level)


func _on_player_died():
	TransitionManager.stop_music()
	await get_tree().create_timer(2.5).timeout
	TransitionManager.transition_to_file_scene(get_tree().current_scene.scene_file_path)


func input_changed() -> void:
	if InputMode.is_gamepad():
		groundtip_1.text = "Left Stick to Move\nX or Stick Down to Sprint"
		groundtip_2.text = "A to Jump"
		groundtip_3.text = "RIGHT BUMPER/TRIGGER TO THROW PICK\nLEFT BUMPER/TRIGGER TO BLOCK BULLETS\nA TO JUMP ON ENEMIES"
	elif InputMode.is_keyboard():
		groundtip_1.text = "WASD or ARROWS to Move\nSHIFT/Middle Mouse to Sprint"
		groundtip_2.text = "SPACE to Jump"
		groundtip_3.text = "LEFT CLICK TO THROW PICK\nRIGHT CLICK TO BLOCK BULLETS\nSPACE TO JUMP ON ENEMIES"


func _on_area_2d_body_entered(body):
	if !combat_triggered:
		wall_2.raise()
		combat_triggered = true
