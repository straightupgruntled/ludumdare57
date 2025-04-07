class_name Turret
extends StaticBody2D

@export var bullet_scene : PackedScene

var health : int = 10
var near_cart : Cart
var near_player : Player
var target_rotation : float = 0.0
var dangerous : bool = false

@onready var gun = $Sprite2D/Gun
@onready var animation_player = $AnimationPlayer
@onready var danger_marker = $DangerMarker
@onready var health_component = $HealthComponent

#SFX#
@onready var aim_sfx = $AimSFX


func _ready():
	scale = Vector2.ZERO
	_on_shoot_timer_timeout()


func _physics_process(delta):
	scale = scale.lerp(Vector2.ONE, .025)
	gun.rotation = lerp_angle(gun.rotation, target_rotation, 0.25)


func _on_shoot_timer_timeout():
	if near_cart:
		target_rotation = (near_cart.global_position - global_position).angle() + randf_range(-PI/12, PI/12)
		aim_sfx.pitch_scale = randf_range(1.0, 1.3)
		aim_sfx.play()
		await get_tree().create_timer(.25).timeout
		shoot()
		await get_tree().create_timer(.25).timeout
		shoot()
	elif near_player:
		target_rotation = (near_player.global_position - global_position).angle() + randf_range(-PI/12, PI/12)
		aim_sfx.pitch_scale = randf_range(1.0, 1.3)
		aim_sfx.play()
		await get_tree().create_timer(.25).timeout
		shoot()
		await get_tree().create_timer(.25).timeout
		shoot()


func shoot() -> void:
	var bullet : EnemyBullet = bullet_scene.instantiate()
	bullet.rotation = target_rotation
	get_parent().add_child(bullet)
	bullet.global_position = global_position


func start_danger() -> void:
	if !dangerous:
		dangerous = true
		danger_marker.trigger()


func take_damage(amount : int = 1) -> void:
	animation_player.stop()
	animation_player.play("hit")
	if health_component.current_health < 5:
		start_danger()


func _on_health_component_died():
	Global.enemies_killed += 1
	if Global.enemies_killed == 3:
		EventBus.tutorial_enemies_killed.emit()
	self.queue_free()


func _on_object_detector_body_entered(body):
	if body is Cart:
		near_cart = body
	elif body is Player:
		near_player = body


func _on_object_detector_body_exited(body):
	if body == near_cart:
		near_cart = null
	elif body == near_player:
		near_player = null
