@tool
class_name Arena
extends Node2D

@export var background_modulate : Color : set = _set_background_modulate
@export var safe_arena : bool = false
@export var animation_player : AnimationPlayer

@onready var canvas_modulate = $CanvasModulate
@onready var tile_map_layer = $TileMapLayer


func _ready():
	if Engine.is_editor_hint():
		return
	if animation_player:
		animation_player.play("dialogue_animation")
	var cells = tile_map_layer.get_used_cells_by_id(1, Vector2(0, 0))
	for child in get_children():
		if child is Spawner:
			child.cell_options = cells


func _set_background_modulate(value : Color) -> void:
	background_modulate = value
	if not is_node_ready():
		await ready
	canvas_modulate.color = background_modulate * 1.5
