class_name CartEquipMenu
extends Control

signal item_equipped(equipment_item : CartEquipItem, snap_dir : CartEquipSnapPoint.Direction)

@export var cart : Cart
@export var item_equipment_1 : CartEquipItem
@export var item_equipment_2 : CartEquipItem
@export var poof_scene : PackedScene

@onready var cart_equipment_cursor = $CartEquipmentCursor


func _ready():
	hide()
	EventBus.minecart_equipment_item_bought.connect(show_menu)
	cart_equipment_cursor.cart_equipment = item_equipment_1
	if cart:
		item_equipped.connect(cart.give_equipment)


func _input(event):
	if event.is_action_pressed("test"):
		show_menu(item_equipment_1)


func show_menu(equipment_item : CartEquipItem) -> void:
	cart_equipment_cursor.cart_equipment = equipment_item
	cart_equipment_cursor.show()
	visible = true
	cart_equipment_cursor.active = visible
	get_tree().paused = visible
	PhysicsServer2D.set_active(true)


func hide_menu() -> void:
	visible = false
	get_tree().paused = visible
	PhysicsServer2D.set_active(true)


func _on_cart_equipment_cursor_place_equipment(equipment_item, snap_point):
	item_equipped.emit(equipment_item, snap_point.point_direction)
	cart_equipment_cursor.active = false
	cart_equipment_cursor.hide()
	var poof = poof_scene.instantiate()
	poof.scale = Vector2(2, 2)
	add_child(poof)
	poof.global_position = cart_equipment_cursor.global_position
	await get_tree().create_timer(0.7).timeout
	hide_menu()
