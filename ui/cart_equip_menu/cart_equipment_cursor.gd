class_name CartEquipmentCursor
extends Node2D

signal place_equipment(equipment_item : MinecartEquipment, snap_point : CartEquipSnapPoint)

@export var cart_equipment : MinecartEquipment : set = _set_cart_equipment

var active : bool = false
var snapping : bool = false
var snap_pos : Vector2
var snap_angle : float = 0.0
var cursor_pos : Vector2 = Vector2(1920/2.0, 1080/2.0)

var time : float = 0.0
var current_snap_point : CartEquipSnapPoint

@onready var equipment_icon = $EquipmentIcon
@onready var cursor_sprite = $CursorSprite


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
	if snapping:
		cursor_sprite.self_modulate = Color.GREEN
		equipment_icon.global_position = equipment_icon.global_position.lerp(snap_pos, .2)
		equipment_icon.global_rotation = lerp_angle(equipment_icon.global_rotation, snap_angle, .2)
		scale = Vector2(2, 2)
	else:
		cursor_sprite.self_modulate = Color.RED
		equipment_icon.position = equipment_icon.position.lerp(Vector2.ZERO, .1)
		equipment_icon.global_rotation = lerp_angle(equipment_icon.global_rotation, -PI/2, .2)
		scale = Vector2(2, 2) * (1 + sin(time * 10.0) * .1) 


func _on_snap_point_detector_area_entered(area):
	snap_pos = area.global_position
	snap_angle = area.global_rotation
	if area is CartEquipSnapPoint:
		current_snap_point = area
	snapping = true


func _on_snap_point_detector_area_exited(area):
	if snapping and area.global_position == snap_pos:
		current_snap_point = null
		snapping = false


func _set_cart_equipment(value : MinecartEquipment) -> void:
	cart_equipment = value
	if not is_node_ready():
		await ready
	equipment_icon.texture = cart_equipment.icon
