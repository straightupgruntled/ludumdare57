class_name Player
extends CharacterBody2D

signal died
signal health_updated(current_health : int)
signal pick_count_updated(amount : int, max_amount : int)

enum State {
	CAN_MOVE,
	DEAD,
	FROZEN
}
@export var current_state : State = State.CAN_MOVE
@export var top_speed : float = 200.0
@export var can_move : bool = true
@export var can_shoot : bool = true
@export var follow_camera : FollowCamera
@export var picks_to_throw : int = 2
@export var max_picks : int = 2 : set = _set_max_picks
@export var pickaxe_scene : PackedScene
@export var poof_particle_scene : PackedScene
@export var back_to_title_on_death : bool = true
@export var hurt_dialogue_options : Array[DialogueMessage]

var first_time_hurt : bool = false
var target_angle : float = 0.0
var knockback_vector : Vector2 = Vector2.ZERO
var time : float = 0.0

@onready var visuals = $Visuals
@onready var body_sprite = $Visuals/BodySprite
@onready var dead_sprite = $Visuals/DeadSprite
@onready var animation_player = $AnimationPlayer
@onready var flashlight = $Flashlight
@onready var health_component = $HealthComponent
@onready var interactor = $Interactor
@onready var hurtbox = $Hurtbox
@onready var stomp_hitbox = $StompHitbox
@onready var bullet_shield = $BulletShield
@onready var object_detector = $ObjectDetector
@onready var height_controller = $HeightController
@onready var death_reset_timer = $DeathResetTimer

#SFX#
@onready var jump_sfx = $SFX/JumpSFX
@onready var land_sfx = $SFX/LandSFX
@onready var pick_throw_sfx = $SFX/PickThrowSFX
@onready var pick_catch_sfx = $SFX/PickCatchSFX


func _ready():
	EventBus.consumable_collected.connect(_consumable_collected)
	body_sprite.show()
	dead_sprite.hide()
	flashlight.hide()
	var poof = create_poof()
	poof.z_index = -999


func _physics_process(delta):
	Global.player_health = health_component.current_health
	match current_state:
		State.CAN_MOVE:
			var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
			velocity = velocity.lerp((input_vector * top_speed) + knockback_vector, 0.5)
			knockback_vector = knockback_vector.lerp(Vector2.ZERO, .05)
			if input_vector.length_squared() > 0.0 and height_controller.is_on_ground():
				time += delta
				visuals.scale = visuals.scale.lerp(Vector2.ONE * (1.0 + sin(time * 21.0) * 0.2), .2)
			elif visuals.scale != Vector2.ONE:
				visuals.scale = visuals.scale.lerp(Vector2.ONE, .2)
			
			if height_controller.is_on_ground():
				if Input.is_action_just_pressed("jump"):
					jump()
				
				if Input.is_action_pressed("shoot"):
					throw_pickaxe()
				
				if Input.is_action_pressed("block"):
					bullet_shield.active = true
					top_speed = 70.0
				elif Input.is_action_pressed("sprint"):
					bullet_shield.active = false
					top_speed = 300.0
				else:
					bullet_shield.active = false
					top_speed = 220.0
			else:
				bullet_shield.active = false
				top_speed = 250.0
			
			if InputMode.is_keyboard():
				mouse_aim()
			elif InputMode.is_gamepad():
				controller_aim()
		State.DEAD:
			velocity = Vector2.ZERO
			global_position = global_position.lerp(follow_camera.global_position, .15)
			rotation = lerp_angle(rotation, PI/2, .15)
			visuals.scale = visuals.scale.lerp(Vector2(2.5, 2.5), .15)
		State.FROZEN:
			velocity = velocity.lerp(Vector2.ZERO, .4)
	
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			var normal = collision.get_normal()
			velocity = velocity.slide(normal)


func set_state(new_state : State) -> void:
	if current_state == State.DEAD:
		return
	current_state = new_state
	match current_state:
		State.CAN_MOVE:
			set_collision_mask_value(4, true)
			set_collision_mask_value(1, true)
			hurtbox.active = true
			for i in 2:
				await get_tree().physics_frame
			height_controller.can_fall = true
			interactor.active = true
		State.DEAD:
			velocity = Vector2.ZERO
			z_index = 999
			hurtbox.active = false
			body_sprite.hide()
			dead_sprite.show()
			flashlight.hide()
			bullet_shield.active = false
			set_collision_mask_value(4, false)
			set_collision_mask_value(1, false)
			height_controller.can_fall = false
			interactor.active = false
			TransitionManager.stop_music()
			died.emit()
			follow_camera.set_deferred("target_node", null)
			follow_camera.global_position = global_position
			death_reset_timer.start()
		State.FROZEN:
			set_collision_mask_value(4, false)
			set_collision_mask_value(1, false)
			height_controller.can_fall = false
			interactor.active = false
			hurtbox.active = false


func mouse_aim() -> void:
	target_angle = (get_global_mouse_position() - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, .2)


func controller_aim() -> void:
	var aim_vector := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_vector.length_squared() > 0.0:
		target_angle = aim_vector.angle()
	rotation = lerp_angle(rotation, target_angle, .2)


func jump() -> void:
	height_controller.jump()
	interactor.active = false
	hurtbox.active = false
	set_collision_mask_value(4, false)
	jump_sfx.pitch_scale = randf_range(0.9, 1.2)
	jump_sfx.play()


func landed_on_ground() -> void:
	interactor.active = true
	stomp_hitbox.active = true
	if can_move:
		hurtbox.active = true
	follow_camera.apply_shake()
	create_poof()
	land_sfx.pitch_scale = randf_range(0.9, 1.4)
	land_sfx.play()
	if object_detector.get_overlapping_bodies().size() > 0:
		for object in object_detector.get_overlapping_bodies():
			if object is Cart:
				push_cart(object)
			if object.has_method("react"):
				object.react()
		jump()
	else:
		set_collision_mask_value(4, true)
	await get_tree().create_timer(.25).timeout
	stomp_hitbox.active = false


func push_cart(cart : Cart) -> void:
	var knock_dir : Vector2 = (cart.global_position - global_position).normalized()
	var look_dir : Vector2 = Vector2(cos(rotation), sin(rotation)).normalized()
	var final_vector = (((look_dir * 2.0) + knock_dir)/2.0).normalized()
	cart.push(final_vector * 250.0)


func throw_pickaxe() -> void:
	if can_shoot and picks_to_throw > 0:
		picks_to_throw -= 1
		pick_count_updated.emit(picks_to_throw, max_picks)
		var pickaxe : PickaxeProjectile = pickaxe_scene.instantiate()
		get_parent().call_deferred("add_child", pickaxe)
		pickaxe.global_position = global_position
		pickaxe.player_ref = self
		pickaxe.throw_dir = Vector2(cos(rotation), sin(rotation)).normalized()
		pick_throw_sfx.pitch_scale = randf_range(1.0, 1.15)
		pick_throw_sfx.play()
		can_shoot = false
		await get_tree().create_timer(.15).timeout
		can_shoot = true


func return_pickaxe(pickaxe : PickaxeProjectile) -> void:
	picks_to_throw += 1
	pick_count_updated.emit(picks_to_throw, max_picks)
	pick_catch_sfx.pitch_scale = randf_range(0.9, 1.1)
	pick_catch_sfx.play()
	pickaxe.queue_free()


func freeze() -> void:
	if not is_node_ready():
		await ready
	set_state(State.FROZEN)


func unfreeze() -> void:
	if not is_node_ready():
		await ready
	set_state(State.CAN_MOVE)


func create_poof() -> InstantParticles:
	var poof = poof_particle_scene.instantiate()
	get_parent().call_deferred("add_child", poof)
	poof.global_position = global_position
	poof.scale = global_scale
	return poof


func use_hyper_boost(hyper_boost : HyperBoostItem) -> void:
	var new_boost_object = hyper_boost.boost_scene.instantiate()
	add_child(new_boost_object)


func _on_health_component_health_lost(new_health):
	animation_player.play("hurt")
	follow_camera.apply_shake()
	health_updated.emit(new_health)


func _on_health_component_health_gained(new_health):
	follow_camera.apply_shake_small()
	health_updated.emit(new_health)


func _on_health_component_died():
	set_state(State.DEAD)


func _on_height_controller_fell_into_pit():
	flashlight.energy = 1.0
	health_component.take_damage(2)
	set_state(State.CAN_MOVE)


func _on_height_controller_falling_started():
	flashlight.energy = 0.0
	set_state(State.FROZEN)


func _set_max_picks(value : int) -> void:
	max_picks = value
	if not is_node_ready():
		await ready
	pick_count_updated.emit(picks_to_throw, max_picks)


func _consumable_collected(consumable_item : ConsumableItem) -> void:
	match consumable_item.id:
		0:
			picks_to_throw += 1
			max_picks += 1
			await get_tree().process_frame
		1:
			health_component.gain_health(2)


func _on_death_reset_timer_timeout():
	pass


func _on_hurtbox_damage_taken(amount):
	Engine.time_scale = 0.1
	await get_tree().create_timer(.025).timeout
	Engine.time_scale = 1.0
	var message = hurt_dialogue_options.pick_random()
	if !DialogueSystem.is_playing():
		DialogueSystem.play_dialogue_message(message)
