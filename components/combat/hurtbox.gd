class_name Hurtbox
extends Area2D

signal damage_taken(amount : int)

enum OwnerType {
	ENEMY = 0,
	PLAYER = 1,
	OBJECT = 2
}
@export var type : OwnerType
@export var health_component : HealthComponent
@export var cooldown_time : float = 0.5
@export var active : bool = true : set = _set_active

var invinsible : bool = false
var cooldown_timer : float = 0.0


func _ready():
	if health_component:
		damage_taken.connect(health_component.take_damage)


func _process(delta):
	if invinsible:
		cooldown_timer += delta
		if cooldown_timer >= cooldown_time:
			invinsible = false
			cooldown_timer = 0.0


func recieve_damage(amount : int) -> void:
	if invinsible:
		return
	damage_taken.emit(amount)
	if cooldown_time > 0.0:
		invinsible = true


func _set_active(value : bool) -> void:
	active = value
	set_deferred("monitorable", active)
	set_deferred("monitoring", active)
