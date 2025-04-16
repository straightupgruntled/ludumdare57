class_name Turret
extends StaticBody2D

@export var bullet_scene : PackedScene
@export var poof_particle_scene : PackedScene
@export var gear_scene : PackedScene

var health : int = 10
var near_cart : Cart
var near_player : Player
var target_rotation : float = 0.0
var dangerous : bool = false
var shots_available : int = 2

@onready var gun = $Sprite2D/Gun
@onready var animation_player = $AnimationPlayer
@onready var danger_marker = $DangerMarker
@onready var health_component = $HealthComponent
@onready var active_light = $ActiveLight
@onready var bullet_marker = $Sprite2D/Gun/BulletMarker
@onready var shoot_timer = $ShootTimer
@onready var wait_timer = $WaitTimer

#SFX#
@onready var aim_sfx = $AimSFX


func _ready():
	scale = Vector2.ZERO
	wait_timer.start()
	active_light.hide()


func _physics_process(delta):
	scale = scale.lerp(Vector2.ONE, .025)
	gun.rotation = lerp_angle(gun.rotation, target_rotation, 0.25)


func shoot() -> void:
	var bullet : EnemyBullet = bullet_scene.instantiate()
	bullet.rotation = target_rotation
	get_tree().current_scene.call_deferred("add_child", bullet)
	bullet.global_position = bullet_marker.global_position


func start_danger() -> void:
	if !dangerous:
		dangerous = true
		danger_marker.trigger()
		wait_timer.wait_time = 1.0


func take_damage(amount : int = 1) -> void:
	animation_player.stop()
	animation_player.play("hit")
	if health_component.current_health < 2:
		start_danger()


func create_poof() -> InstantParticles:
	var poof = poof_particle_scene.instantiate()
	get_parent().call_deferred("add_child", poof)
	poof.global_position = global_position
	poof.scale = global_scale
	return poof


func create_gear() -> void:
	var gear : Gear = gear_scene.instantiate()
	get_parent().call_deferred("add_child", gear)
	gear.global_position = global_position
	gear.rotation = randf_range(0.0, 2*PI)
	gear.velocity = Vector2.RIGHT.rotated(randf_range(0.0, 2*PI)) * 200.0


func _on_health_component_died():
	Global.enemies_killed += 1
	if Global.enemies_killed == 3:
		EventBus.tutorial_enemies_killed.emit()
	set_collision_layer_value(4, false)
	create_poof()
	hide()
	for i in randi_range(2, 3):
		await get_tree().create_timer(0.025).timeout
		create_gear()
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


func _on_wait_timer_timeout():
	if near_player:
		active_light.show()
		target_rotation = (near_player.global_position - global_position).angle() + randf_range(-PI/12, PI/12)
		aim_sfx.pitch_scale = randf_range(1.0, 1.3)
		aim_sfx.play()
		shoot_timer.start()
	elif near_cart:
		active_light.show()
		target_rotation = (near_cart.global_position - global_position).angle() + randf_range(-PI/12, PI/12)
		aim_sfx.pitch_scale = randf_range(1.0, 1.3)
		aim_sfx.play()
		shoot_timer.start()
	else:
		active_light.hide()
		wait_timer.start()


func _on_shoot_timer_timeout():
	if shots_available > 0:
		shoot()
		shots_available -= 1
		shoot_timer.start()
	else:
		wait_timer.start()
		shots_available = 2
