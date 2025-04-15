class_name PickUI
extends GridContainer

@export var pick_count : int = 4


func _ready():
	update_pick_count(2, 2)


func update_pick_count(count : int, max_picks : int) -> void:
	var id : int = 0
	for child in get_children():
		child.hide()
	for i in max_picks:
		get_child(i).show()
	for child in get_children():
		if id < count:
			child.modulate = Color.WHITE
		else:
			child.modulate = Color.DIM_GRAY
		id += 1
