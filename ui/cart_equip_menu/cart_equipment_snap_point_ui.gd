class_name CartEquipSnapPoint
extends Area2D

enum Direction {
	FORWARD,
	LEFT,
	RIGHT,
	FORWARD_LEFT,
	FORWARD_RIGHT,
	BACK_LEFT,
	BACK_RIGHT
}
@export var point_direction : Direction
@export var cart_equipment : CartEquipItem : set = _set_cart_equipment

@onready var cart_equipment_item = $CartEquipmentItem


func _ready():
	cart_equipment_item.hide()


func give_equipment_item(equipment_item : CartEquipItem) -> void:
	cart_equipment = equipment_item
	cart_equipment_item.show()
	monitorable = false
	monitoring = false


func _set_cart_equipment(value : CartEquipItem) -> void:
	cart_equipment = value
	if not is_node_ready():
		await ready
	cart_equipment_item.texture = cart_equipment.icon
