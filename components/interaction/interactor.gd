class_name Interactor
extends Area2D

@export var owner_body : CharacterBody2D
@export var active : bool = true : set = _set_active

var current_interactable : Interactable


func _input(event):
	set_physics_process(active)
	if current_interactable:
		if event.is_action_pressed("interact") and !current_interactable.descent_interactor:
			current_interactable.trigger(self)
		if event.is_action_pressed("continue_descent") and current_interactable.descent_interactor:
			current_interactable.trigger(self)


func _physics_process(delta):
	if !monitoring:
		return
	var closest_distance = 100000.0
	var target_interactable : Interactable
	for interactable in get_overlapping_areas():
		var distance = (interactable.global_position - global_position).length_squared()
		if distance < closest_distance:
			closest_distance = distance
			target_interactable = interactable
	if target_interactable != current_interactable:
		if current_interactable:
			current_interactable.hide_interaction()
		current_interactable = target_interactable
		if current_interactable:
			current_interactable.show_interaction()



func _on_area_exited(area):
	if area is Interactable:
		area.hide_interaction()
		if area == current_interactable:
			current_interactable = null


func _set_active(value : bool) -> void:
	active = value
	set_physics_process(active)
	set_deferred("monitorable", active)
	set_deferred("monitoring", active)
