class_name CartEquipmentCursor
extends Node2D

signal place_equipment(equipment_item : CartEquipItem, snap_point : CartEquipSnapPoint)

@export var cart_equipment : CartEquipItem : set = _set_cart_equipment

var active : bool = false
var snapping : bool = false
var snap_pos : Vector2
var snap_angle : float = 0.0
var cursor_pos : Vector2 = Vector2(1920/2.0, 1080/2.0)
var current_snap_point : CartEquipSnapPoint
var time : float = 0.0

@onready var equipment_icon = $EquipmentIcon
@onready var snap_point_detector = $SnapPointDetector


func _input(event):
	if !active:
		return
	if current_snap_point and event.is_action_pressed("ui_select"):
		current_snap_point.give_equipment_item(cart_equipment)
		place_equipment.emit(cart_equipment, current_snap_point)


func _process(delta):
	if !active:
		return
	time += delta
	if InputMode.is_keyboard():
		cursor_pos = get_global_mouse_position()
	elif InputMode.is_gamepad():
		cursor_pos += Input.get_vector("move_left", "move_right", "move_up", "move_down") * 5.0
	global_position += (cursor_pos - global_position) * 0.15
	
	if snap_point_detector.get_overlapping_areas().size() > 0:
		var closest_distance : int = 100000
		for snap_area in snap_point_detector.get_overlapping_areas():
			var distance = (snap_area.global_position - global_position).length()
			if distance < closest_distance:
				closest_distance = distance
				current_snap_point = snap_area
		snap_pos = current_snap_point.global_position
		snap_angle = current_snap_point.global_rotation
		snapping = true
	else:
		current_snap_point = null
		snapping = false
	
	if snapping:
		equipment_icon.global_position = equipment_icon.global_position.lerp(snap_pos, .1)
		equipment_icon.global_rotation = lerp_angle(equipment_icon.global_rotation, snap_angle, .3)
		scale = Vector2(2, 2)
	else:
		equipment_icon.position = equipment_icon.position.lerp(Vector2.ZERO, .1)
		equipment_icon.global_rotation = lerp_angle(equipment_icon.global_rotation, snap_angle, .3)
		scale = Vector2(2, 2) * (1 + sin(time * 10.0) * .1) 


func _set_cart_equipment(value : CartEquipItem) -> void:
	cart_equipment = value
	if not is_node_ready():
		await ready
	equipment_icon.texture = cart_equipment.icon
