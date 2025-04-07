class_name Level
extends Node2D

@export_file() var next_level : String

@onready var floor_objects = $FloorObjects
@onready var follow_camera = $FollowCamera

@export var player : Player
@export var cart : Cart

func _ready():
	if player:
		player.light_active = true
		player.can_move = true


func platform_entrance_complete(platform : Platform) -> void:
	player = platform.near_player
	cart = platform.near_cart
	if !player or !cart:
		return
	player.light_active = true
	player.reparent(self)
	cart.reparent(self)
	if not is_node_ready():
		await ready
	follow_camera.target_node = player
	player.can_move = true


func platform_descent_started(platform : Platform) -> void:
	follow_camera.target_node = platform
	follow_camera.descending = true
	player.freeze()
	await get_tree().create_timer(2.0).timeout
	TransitionManager.transition_to_file_scene(next_level)


func _on_player_died():
	$Music.stop()
