@tool
class_name UIMenu
extends VBoxContainer

@export var mouse_mode : bool = false : set = _set_mouse_mode
@export var is_open : bool = false : set = _set_is_open


func _input(event):
	if event is InputEventMouseMotion and !mouse_mode:
		mouse_mode = true

	if (event.is_action("ui_up") or event.is_action("ui_down")) and mouse_mode:
		mouse_mode = false
		if is_open:
			focus_first_visible()


func open() -> void:
	is_open = true


func close() -> void:
	is_open = false


func focus_first_visible() -> void:
	var target_node
	for child in get_all_children(self):
		if child.visible:
			if child is Button or child is Range:
				target_node = child
				break
	await get_tree().process_frame
	if target_node:
		target_node.grab_focus()


func _set_mouse_mode(value : bool) -> void:
	mouse_mode = value
	if not is_node_ready():
		await ready 
	if mouse_mode:
		for child in get_all_children(self):
			if child.visible:
				if child is Button or child is Range:
					child.release_focus()
	elif is_open:
		for child in get_all_children(self):
			if child.visible:
				if child is Button or child is Range:
					child.release_focus()
					hide()
					child.focus_mode = Control.FOCUS_NONE
					show()
					child.focus_mode = Control.FOCUS_ALL
		await get_tree().process_frame
		focus_first_visible()


func _set_is_open(value : bool) -> void:
	is_open = value
	if not is_node_ready():
		await ready
	visible = is_open
	if is_open:
		for element in get_all_children(self):
			if element is BaseButton or element is Range:
				element.focus_mode = Control.FOCUS_ALL
			else:
				element.focus_mode = Control.FOCUS_NONE
		if !mouse_mode:
			focus_first_visible()
	else:
		for element in get_all_children(self):
			if element is Control:
				element.release_focus()
				element.focus_mode = Control.FOCUS_NONE


func get_all_children(target_node : Node) -> Array:
	var nodes : Array = []
	for node in target_node.get_children():
		if node.get_child_count() > 0:
			nodes.append(node)
			nodes.append_array(node.get_children())
		else:
			nodes.append(node)
	return nodes
