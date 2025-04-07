extends Area2D

@export var object_scene : PackedScene
@export var spawn_delay : float = 5.0
@export var entity_cap : int = 5
@export var active : bool = true
@export var object_spawn_layer : Node2D

@onready var ground_collider = $GroundCollider

var entity_count : int = 0


func _ready():
	$SpawnTimer.wait_time = spawn_delay
	$SpawnTimer.start()


func attempt_to_spawn() -> void:
	if !active or entity_count >= entity_cap:
		return
	global_position = Vector2(randf_range(32.0, 32.0 * 25.0), randf_range(32.0, 32.0 * 25.0))
	force_update_transform()
	ground_collider.force_update_transform()
	await get_tree().physics_frame
	if get_overlapping_bodies().size() > 0:
		attempt_to_spawn()
		return
	if ground_collider.get_overlapping_bodies().is_empty():
		return
	spawn_object()


func spawn_object() -> void:
	var object = object_scene.instantiate()
	object_spawn_layer.add_child(object)
	object.global_position = global_position
	object.tree_exited.connect(_entity_removed)
	entity_count += 1


func _entity_removed() -> void:
	entity_count -= 1
