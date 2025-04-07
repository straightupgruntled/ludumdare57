class_name HeightBody2D
extends CharacterBody2D

signal landed_on_ground
signal fell_into_pit

@export var visuals : Node2D
@export var can_respawn : bool = true

var height : float = 0.0
var gravity : float = 0.0
var start_scale : Vector2
var spawn_pos : Vector2

@export var can_fall : bool = false

var near_cart : Cart

enum State {
	GROUNDED,
	AIRBORNE,
	FALLING
}
var current_state : State = State.GROUNDED

@onready var ground_detector = $GroundDetector
@onready var respawn_timer = $RespawnTimer


func _ready():
	spawn_pos = global_position
	start_scale = visuals.scale
	for i in 2:
		await get_tree().physics_frame
	can_fall = true


func _physics_process(delta):
	height += gravity
	match current_state:
		State.GROUNDED:
			z_index = 0
			height = 0.0
			gravity = 0.0
			if ground_detector.get_overlapping_bodies().is_empty() and can_fall:
				current_state = State.FALLING
		State.AIRBORNE:
			z_index = 1
			gravity -= 1.0
			if height <= 0.0:
				landing()
		State.FALLING:
			z_index = -1
			visuals.modulate = visuals.modulate.lerp(Color.BLACK, .175)
			if height < -190:
				gravity = 0.0
				fell_into_pit.emit()
				if can_respawn:
					respawn()
				else:
					queue_free()
			elif height >= -190:
				gravity -= 1.0
	var scale_remap = remap(height, 0.0, 200.0, 1.0, 2.0)
	visuals.scale = start_scale * scale_remap


func jump() -> void:
	set_collision_mask_value(5, false)
	set_collision_mask_value(4, false)
	gravity = 20.0
	current_state = State.AIRBORNE


func landing() -> void:
	if ground_detector.get_overlapping_bodies().is_empty():
		current_state = State.FALLING
	else:
		current_state = State.GROUNDED
		set_collision_mask_value(5, true)
		set_collision_mask_value(4, true)
		landed_on_ground.emit()


func respawn():
	velocity = Vector2.ZERO
	rotation = 0.0
	current_state = State.GROUNDED
	global_position = spawn_pos
	visuals.modulate = Color.WHITE
	set_collision_mask_value(5, true)
	set_collision_mask_value(4, true)


func is_on_ground() -> bool:
	return current_state == State.GROUNDED


func _on_cart_detector_body_entered(body):
	near_cart = body


func _on_cart_detector_body_exited(body):
	if body == near_cart:
		near_cart = null
