class_name HeightController
extends Area2D

signal in_air_started
signal landed_on_ground
signal fell_into_pit

@export var body : CharacterBody2D
@export var visuals : Node2D
@export var can_respawn : bool = true
@export var can_fall : bool = false
@export var ground_exceptions : Array[Node2D]

enum State {
	GROUNDED,
	AIRBORNE,
	FALLING
}
var current_state : State = State.GROUNDED

var height : float = 0.0
var fall_gravity : float = 0.0
var spawn_pos : Vector2
var spawn_scale : Vector2
var ground_bodies : Array[Node2D]

@onready var respawn_timer = $RespawnTimer


func _ready():
	spawn_pos = body.global_position
	spawn_scale = visuals.scale
	for i in 2:
		await get_tree().physics_frame
	can_fall = true


func _physics_process(delta):
	height += fall_gravity
	match current_state:
		State.GROUNDED:
			if ground_bodies.is_empty() and can_fall:
				set_state(State.FALLING)
		State.AIRBORNE:
			fall_gravity -= 1.0
			if height <= 0.0:
				landing()
		State.FALLING:
			visuals.modulate = visuals.modulate.lerp(Color.BLACK, .175)
			if height < -190:
				fall_gravity = 0.0
				fell_into_pit.emit()
				if can_respawn:
					respawn()
				else:
					queue_free()
			elif height >= -190:
				fall_gravity -= 1.0

	var scale_remap = remap(height, 0.0, 200.0, 1.0, 2.0)
	visuals.scale = spawn_scale * scale_remap


func set_state(new_state : State) -> void:
	current_state = new_state
	match current_state:
		State.GROUNDED:
			body.z_index = 0
			height = 0.0
			fall_gravity = 0.0
		State.AIRBORNE:
			body.z_index = 1
			in_air_started.emit()
		State.FALLING:
			body.z_index = -1


func jump(upward_force : float = 20.0) -> void:
	fall_gravity = upward_force
	set_state(State.AIRBORNE)


func landing() -> void:
	if ground_bodies.is_empty():
		set_state(State.FALLING)
	else:
		set_state(State.GROUNDED)
		landed_on_ground.emit()


func respawn():
	set_state(State.GROUNDED)
	body.global_position = spawn_pos
	body.rotation = 0.0
	body.velocity = Vector2.ZERO
	visuals.modulate = Color.WHITE
	force_update_transform()
	await get_tree().physics_frame
	landing()


func is_on_ground() -> bool:
	return current_state == State.GROUNDED


func _on_body_entered(new_body):
	if not new_body in ground_exceptions:
		ground_bodies.append(new_body)


func _on_body_exited(new_body):
	if new_body in ground_bodies:
		ground_bodies.erase(new_body)
