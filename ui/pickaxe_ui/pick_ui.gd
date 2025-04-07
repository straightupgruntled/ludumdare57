class_name PickUI
extends HBoxContainer

@export var pick_count : int = 4


func _ready():
	if pick_count < 5:
		for i in 5 - pick_count:
			get_child(0).queue_free()
			await get_tree().process_frame


func update_pick_count(count : int) -> void:
	var id : int = 0
	for child in get_children():
		if id < count:
			child.modulate = Color.WHITE
		else:
			child.modulate = Color.DIM_GRAY
		id += 1
