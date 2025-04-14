@tool
class_name CollectableMagnet
extends Area2D

@export var offset_amount : int = 0 : set= _set_offset_amount

@onready var collect_marker = $CollectMarker


func _ready():
	if Engine.is_editor_hint():
		collect_marker.show()
	else:
		collect_marker.hide()


func _physics_process(delta):
	for collectable in get_overlapping_bodies():
		if collectable is CharacterBody2D:
			var distance_vector = (collect_marker.global_position - collectable.global_position).normalized() * 10.0
			collectable.velocity += Vector2.ONE * distance_vector


func _set_offset_amount(value : int) -> void:
	offset_amount = value
	if not is_node_ready():
		await ready
	collect_marker.global_position = global_position - Vector2(cos(global_rotation), sin(global_rotation)) * offset_amount
