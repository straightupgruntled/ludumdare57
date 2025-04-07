class_name HealthComponent
extends Node

signal health_lost(new_health : int)
signal health_gained(new_health : int)
signal died

@export var max_health : int = 10

@onready var current_health : int = max_health : set = _set_current_health


func take_damage(amount : int) -> void:
	if current_health == 0:
		return
	current_health -= amount
	health_lost.emit(current_health)
	if current_health == 0:
		died.emit()


func gain_health(amount : int) -> void:
	current_health += amount
	health_gained.emit(current_health)


func _set_current_health(value : int) -> void:
	current_health = value
	current_health = clamp(current_health, 0, max_health)
