class_name Spawner
extends Area2D

@export var spawn_root : Node2D
@export var object_scene : PackedScene
@export var spawn_delay : float = 5.0 : set = _set_spawn_delay
@export var entity_cap : int = 5
@export var active : bool = true
@onready var spawn_timer = $SpawnTimer

@onready var ground_collider = $GroundCollider
@onready var object_detector = $ObjectDetector

var entity_count : int = 0
var cell_options : Array
var spawn_attempts : int = 0
var can_place : bool = true


func _ready():
	spawn_timer.wait_time = spawn_delay
	spawn_timer.start()
	hide()


func attempt_to_spawn() -> void:
	if spawn_attempts > 30:
		can_place = true
		spawn_attempts = 0
		return
	if !active or entity_count >= entity_cap:
		return
	if !get_tree():
		return
	global_position = cell_options.pick_random() * 32
	force_update_transform()
	ground_collider.force_update_transform()
	spawn_attempts += 1
	await get_tree().physics_frame
	if get_overlapping_areas().size() > 0:
		await attempt_to_spawn()
		return
	elif get_overlapping_bodies().size() > 0 or object_detector.get_overlapping_bodies().size() > 0:
		await attempt_to_spawn()
		return
	elif ground_collider.get_overlapping_bodies().is_empty():
		await attempt_to_spawn()
		return
	else:
		spawn_object()


func spawn_object() -> void:
	var object = object_scene.instantiate()
	get_parent().call_deferred("add_child", object)
	object.global_position = global_position
	object.scale = Vector2.ZERO
	object.tree_exited.connect(_entity_removed)
	entity_count += 1
	can_place = true


func _entity_removed() -> void:
	entity_count -= 1


func _set_spawn_delay(value : float) -> void:
	spawn_delay = value
	if not is_node_ready():
		await ready
	spawn_timer.wait_time = spawn_delay


func _on_spawn_timer_timeout():
	if active or entity_count < entity_cap:
		can_place = true
	if can_place:
		can_place = false
		await attempt_to_spawn()
