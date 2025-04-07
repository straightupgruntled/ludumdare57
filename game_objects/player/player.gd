class_name Player
extends CharacterBody2D

signal died
signal health_updated(current_health : int)
signal pick_count_updated(amount : int)

@export var top_speed : float = 200.0
@export var can_move : bool = true
@export var can_shoot : bool = true
@export var light_active : bool = false : set = _set_light_active
@export var follow_camera : FollowCamera
@export var is_dead : bool = false
@export var picks_to_throw : int = 2
@export var pickaxe_scene : PackedScene
@export var poof_particle_scene : PackedScene
@export var object_spawn_layer : Node2D


var cart_near : Cart
var target_angle : float = 0.0
var knockback_vector : Vector2 = Vector2.ZERO

@onready var collision_shape = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var flashlight = $Flashlight
@onready var circle_light = $CircleLight
@onready var health_component = $HealthComponent
@onready var stomp_hitbox = $StompHitbox
@onready var bullet_shield = $BulletShield
@onready var object_detector = $ObjectDetector
@onready var height_controller = $HeightController
@onready var hurtbox = $Hurtbox

#SFX#
@onready var jump_sfx = $JumpSFX
@onready var land_sfx = $LandSFX
@onready var pick_throw_sfx = $PickThrowSFX
@onready var pick_catch_sfx = $PickCatchSFX


func _ready():
	light_active = false


func _input(event):
	if !can_move:
		return
	if event.is_action_pressed("jump") and height_controller.is_on_ground():
		height_controller.jump()
		jump_sfx.pitch_scale = randf_range(0.9, 1.2)
		jump_sfx.play()


func _physics_process(delta):
	if is_dead:
		scale = Vector2(2, 2)
		global_position = global_position.lerp(follow_camera.global_position, .1)
		rotation = lerp_angle(rotation, PI/2, .25)
		return
	var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.lerp((input_vector * top_speed) + knockback_vector, 0.25)
	knockback_vector = knockback_vector.lerp(Vector2.ZERO, .05)
	if can_move:
		if InputMode.is_keyboard():
			mouse_aim()
		elif InputMode.is_gamepad():
			controller_aim()
		move_and_slide()

		if Input.is_action_pressed("shoot") and can_shoot:
			if height_controller.is_on_ground() and picks_to_throw > 0:
				throw_pickaxe()
				can_shoot = false
				await get_tree().create_timer(.15).timeout
				can_shoot = true
	
	if Input.is_action_pressed("block") and height_controller.is_on_ground() and can_move:
		bullet_shield.active = true
		top_speed = 70.0
	elif Input.is_action_pressed("sprint"):
		bullet_shield.active = false
		top_speed = 300.0
	else:
		bullet_shield.active = false
		top_speed = 220.0


func controller_aim() -> void:
	var aim_vector := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_vector.length_squared() > 0.0:
		target_angle = aim_vector.angle()
	rotation = lerp_angle(rotation, target_angle, .2)


func mouse_aim() -> void:
	target_angle = (get_global_mouse_position() - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, .2)


func landed_on_ground() -> void:
	stomp_hitbox.active = true
	follow_camera.apply_shake()
	hurtbox.active = true
	land_sfx.pitch_scale = randf_range(0.9, 1.4)
	land_sfx.play()
	var poof = poof_particle_scene.instantiate()
	object_spawn_layer.add_child(poof)
	poof.global_position = global_position
	if cart_near:
		push_cart(cart_near)
		height_controller.jump()
		jump_sfx.pitch_scale = randf_range(0.9, 1.2)
		jump_sfx.play()
	elif object_detector.get_overlapping_bodies().size() > 0:
		for object in object_detector.get_overlapping_bodies():
			if object is Turret:
				if object.dangerous:
					health_component.take_damage(2)
					knockback_vector = (global_position - object.global_position).normalized() * 350.0
		height_controller.jump()
		jump_sfx.pitch_scale = randf_range(0.9, 1.2)
		jump_sfx.play()
	else:
		set_collision_mask_value(4, true)
	await get_tree().create_timer(.25).timeout
	stomp_hitbox.active = false


func push_cart(cart : Cart) -> void:
	var knock_dir : Vector2 = (cart.global_position - global_position).normalized()
	var look_dir : Vector2 = Vector2(cos(rotation), sin(rotation)).normalized()
	var final_vector = (((look_dir * 2.0) + knock_dir)/2.0).normalized()
	cart.velocity = final_vector * 310.0


func throw_pickaxe() -> void:
	pick_throw_sfx.pitch_scale = randf_range(1.0, 1.15)
	pick_throw_sfx.play()
	picks_to_throw -= 1
	pick_count_updated.emit(picks_to_throw)
	var pickaxe : PickaxeProjectile = pickaxe_scene.instantiate()
	get_parent().add_child(pickaxe)
	pickaxe.global_position = global_position
	pickaxe.player_ref = self
	pickaxe.throw_dir = Vector2(cos(rotation), sin(rotation)).normalized()


func return_pickaxe(pickaxe : PickaxeProjectile) -> void:
	picks_to_throw += 1
	pick_count_updated.emit(picks_to_throw)
	pick_catch_sfx.pitch_scale = randf_range(0.9, 1.1)
	pick_catch_sfx.play()
	pickaxe.queue_free()


func freeze() -> void:
	light_active = false
	flashlight.set_deferred("energy", 0.0)
	circle_light.set_deferred("energy", 1.0)
	collision_shape.set_deferred("disabled", true)
	height_controller.can_fall = false
	hurtbox.active = false
	can_move = false


func _set_light_active(value : bool) -> void:
	light_active = value
	if not is_node_ready():
		await ready
	if light_active:
		flashlight.energy = 1.0
	else:
		flashlight.energy = 0.0


func _on_height_controller_in_air_started():
	hurtbox.active = false
	set_collision_mask_value(4, false)


func _on_object_detector_body_entered(body):
	if body is Cart:
		cart_near = body


func _on_object_detector_body_exited(body):
	if body == cart_near:
		cart_near = null


func _on_health_component_health_lost(new_health):
	animation_player.play("hurt")
	follow_camera.apply_shake()
	health_updated.emit(new_health)


func _on_health_component_died():
	is_dead = true
	died.emit()
	follow_camera.set_deferred("target_node", null)
	flashlight.set_deferred("energy", 0.0)
	circle_light.set_deferred("energy", 1.0)
	collision_shape.set_deferred("disabled", true)
	height_controller.can_fall = false
	hurtbox.active = false
	await get_tree().create_timer(2.0).timeout
	TransitionManager.transition_to_file_scene(get_tree().current_scene.scene_file_path)


func _on_height_controller_fell_into_pit():
	health_component.take_damage(2)
