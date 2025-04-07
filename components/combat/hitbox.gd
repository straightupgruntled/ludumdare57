class_name Hitbox
extends Area2D

signal hit_hurtbox

enum OwnerType {
	ENEMY = 0,
	PLAYER = 1,
	OBJECT = 2
}
@export var type : OwnerType
@export var damage_amount : int = 1
@export var active : bool = true : set = _set_active


func _on_area_entered(area):
	if not area is Hurtbox:
		return
	var target_hurtbox : Hurtbox = area
	if target_hurtbox.type != type:
		target_hurtbox.recieve_damage(damage_amount)
		hit_hurtbox.emit()


func _set_active(value : bool) -> void:
	active = value
	monitorable = active
	monitoring = active
