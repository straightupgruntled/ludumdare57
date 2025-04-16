@tool
class_name BulletShield
extends Area2D

@export var active : bool : set = _set_active

@onready var collision_shape = $CollisionShape2D
@onready var collision_shape_2 = $CollisionShape2D2
@onready var collision_shape_3 = $CollisionShape2D3


#SFX#
@onready var deflect_sfx = $DeflectSFX


func _set_active(value : bool) -> void:
	if active == value:
		return
	active = value
	if !is_node_ready():
		await ready
	visible = active
	collision_shape.set_deferred("disabled", !active)
	collision_shape_2.set_deferred("disabled", !active)
	collision_shape_3.set_deferred("disabled", !active)


func _on_body_entered(body):
	if body is EnemyBullet:
		if !body.bounced:
			var bullet : EnemyBullet = body
			bullet.player_claim()
			bullet.move_dir = Vector2(cos(global_rotation), sin(global_rotation))
			bullet.speed *= 1.6
			bullet.bounced = true
			deflect_sfx.pitch_scale = randf_range(0.9, 1.1)
			deflect_sfx.play()
