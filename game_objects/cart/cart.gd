class_name Cart
extends CharacterBody2D

enum MoveMode {
	FREE,
	PLAYER_PUSH,
	FROZEN
}
@export var collision_shapes : Array[CollisionShape2D]
@export var current_move_mode : MoveMode = MoveMode.FREE
@export var top_speed : float = 250.0
@export var diamonds_collected : int = 0 : set = _set_diamonds_collected
@export var gears_collected : int = 0 : set = _set_gears_collected
@export var double_quota_dialogue : DialogueMessage
@export var quota_reached_dialogue : DialogueMessage

@export_group("Weight Speed Effects")
@export var max_item_count : int = 100
@export var full_speed_modifier : float = 0.25

var player_ref : Player
var player_can_release : bool = false
var turn_speed : float = 0.0
var move_speed : float = top_speed
var move_backwards : bool = false
var is_hoarding : bool = false
var target_rotation : float = 0.0

@onready var visuals = $Visuals
@onready var sprite = $Visuals/Sprite2D
@onready var fixed_pivot = $Visuals/FixedPivot
@onready var diamond_count_label = $Visuals/FixedPivot/DiamondCountLabel
@onready var gear_count_label = $Visuals/FixedPivot/GearCountLabel
@onready var animation_player = $Visuals/AnimationPlayer
@onready var player_collision = $PlayerCollision
@onready var height_controller = $HeightController
@onready var hurtbox = $Hurtbox
@onready var interactable = $Interactable

# Attachment Points #
@onready var front_equip = $Visuals/AttachmentAnchors/Front
@onready var left_equip = $Visuals/AttachmentAnchors/Left
@onready var right_equip = $Visuals/AttachmentAnchors/Right
@onready var front_left_equip = $Visuals/AttachmentAnchors/FrontLeft
@onready var front_right_equip = $Visuals/AttachmentAnchors/FrontRight
@onready var back_left_equip = $Visuals/AttachmentAnchors/BackLeft
@onready var back_right_equip = $Visuals/AttachmentAnchors/BackRight

# SFX #
@onready var collect_sparkle = $CollectSparkle


func _ready():
	freeze()


func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_can_release:
		release_player()


func _physics_process(delta):
	fixed_pivot.global_rotation = 0.0
	sprite.scale = sprite.scale.lerp(Vector2.ONE * 0.5, .2)
	diamond_count_label.scale = diamond_count_label.scale.lerp(Vector2.ONE * 0.5, .2)
	gear_count_label.scale = gear_count_label.scale.lerp(Vector2.ONE * 0.5, .2)
	match current_move_mode:
		MoveMode.FREE:
			velocity = velocity.move_toward(Vector2.ZERO, 5.25)
			var collision = move_and_collide(velocity * delta)
			if collision:
				var collider = collision.get_collider()
				if collider is Rock and velocity.length() > 50.0:
					collider.health_component.take_damage(1)
				velocity = velocity.reflect(collision.get_normal().rotated(PI/2)) * 0.9
				move_backwards = true
				if velocity.length() > 50.0:
					pulse(1.35)
			rotation = lerp_angle(rotation, target_rotation, .15)
		MoveMode.PLAYER_PUSH:
			if player_ref.current_state == Player.State.DEAD:
				release_player()
				return
			player_ref.global_position = player_ref.global_position.lerp(player_collision.global_position, .7)
			player_ref.rotation = lerp_angle(player_ref.rotation, (global_position - player_ref.global_position).angle(), .3)
			target_rotation = rotation
			var item_count = diamonds_collected + gears_collected
			var speed_modif = clamp(remap(item_count, 0, max_item_count, 1.0, full_speed_modifier), full_speed_modifier, 1.0)
			if InputMode.is_gamepad():
				var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
				if input_vector.length() > 0.5:
					rotation = lerp_angle(rotation, input_vector.angle(), .1)
					velocity = velocity.lerp(input_vector * move_speed * speed_modif, .15)
				else:
					velocity = velocity.lerp(Vector2.ZERO, .15)
			elif InputMode.is_keyboard():
				rotation = lerp_angle(rotation, (get_global_mouse_position() - global_position).angle(), .15)
				var forward_input : float = Input.get_action_strength("move_up") - Input.get_action_strength("move_down") * 0.5
				if forward_input > 0:
					move_backwards = false
				else:
					move_backwards = true
				var input_vector : Vector2 = Vector2(cos(rotation), sin(rotation)) * forward_input
				velocity = velocity.lerp(input_vector * move_speed * speed_modif, .2)
			move_and_slide()
			for i in range(get_slide_collision_count()):
				var collision = get_slide_collision(i)
				if collision:
					var normal = collision.get_normal()
					velocity = velocity.slide(normal)
		MoveMode.FROZEN:
			velocity = velocity.lerp(Vector2.ZERO, .2)
			move_and_slide()


func set_current_move_mode(new_move_move : MoveMode) -> void:
	current_move_mode = new_move_move
	move_backwards = false


func push(force_vector : Vector2) -> void:
	move_backwards = false
	velocity = force_vector * 200.0
	target_rotation = velocity.angle()
	pulse()


func pulse(amount : float = 1.25) -> void:
	sprite.scale = Vector2(0.5, 0.5) * amount


func take_damage(amount : int) -> void:
	if diamonds_collected > 0 and gears_collected > 0:
		var rand_chance : int = randi_range(0, 10)
		if rand_chance < 8:
			diamonds_collected -= amount
		else:
			gears_collected -= amount
	elif gears_collected == 0:
		diamonds_collected -= amount
	elif diamonds_collected == 0:
		gears_collected -= amount
	if diamonds_collected < 0:
		diamonds_collected = 0
	animation_player.play("hurt")


#func lock_to_platform() -> void:
	#height_controller.can_fall = false
	#hurtbox.active = false
	#interactable.active = false
	#set_current_move_mode(MoveMode.LOCKED_TO_PLATFORM)
#
#
#func unlock_from_platform() -> void:
	#height_controller.can_fall = true
	#hurtbox.active = true
	#interactable.active = true
	#set_current_move_mode(MoveMode.FREE)


func freeze() -> void:
	height_controller.can_fall = false
	hurtbox.active = false
	interactable.active = false
	current_move_mode = MoveMode.FROZEN
	is_hoarding = false
	for col_shape in collision_shapes:
		col_shape.set_deferred("disabled", true)


func unfreeze() -> void:
	height_controller.can_fall = true
	hurtbox.active = true
	interactable.active = true
	current_move_mode = MoveMode.FREE
	for col_shape in collision_shapes:
		col_shape.set_deferred("disabled", false)


func release_player() -> void:
	player_collision.set_deferred("disabled", true)
	if player_ref:
		player_ref.unfreeze()
		player_ref.follow_camera.target_node = player_ref
		player_ref = null
	set_current_move_mode(MoveMode.FREE)


func _on_collectable_detector_body_entered(body):
	if body is Diamond:
		diamonds_collected += 1
		if diamonds_collected == Global.diamond_requirement:
			DialogueSystem.play_dialogue_message(quota_reached_dialogue)
		if diamonds_collected >= Global.diamond_requirement * 2 and !is_hoarding:
			DialogueSystem.play_dialogue_message(double_quota_dialogue)
			is_hoarding = true
	elif body is Gear:
		gears_collected += 1
	elif body is ConsumableCollectable:
		EventBus.consumable_collected.emit(body.consumable_item)
	elif body is CartEquipCollectable:
		EventBus.minecart_equipment_item_bought.emit(body.cart_equip_item)
	collect_sparkle.pitch_scale = randf_range(0.9, 1.35)
	collect_sparkle.play()
	body.queue_free()

func _on_interactable_interaction_triggered(interactor : Interactor):
	var body = interactor.owner_body
	if body is Player:
		player_grab_cart(body)


func player_grab_cart(player : Player) -> void:
	player_ref = player
	player_collision.set_deferred("disabled", false)
	player_ref.start_pushing_cart()
	player_ref.follow_camera.target_node = self
	player_can_release = false
	set_current_move_mode(MoveMode.PLAYER_PUSH)
	await get_tree().process_frame
	player_can_release = true


func _on_height_controller_fall_started():
	interactable.active = false
	set_collision_layer_value(4, false)
	if player_ref:
		release_player()


func _on_height_controller_fell_into_pit():
	interactable.active = true
	diamonds_collected = ceil(float(diamonds_collected) * 0.5)
	gears_collected = ceil(float(gears_collected) * 0.5)
	set_collision_layer_value(4, true)


func _set_diamonds_collected(value : int) -> void:
	diamonds_collected = value
	if diamonds_collected < 0:
		diamonds_collected = 0
	if not is_node_ready():
		await ready
	diamond_count_label.text = str(diamonds_collected)
	diamond_count_label.scale = Vector2.ONE


func _set_gears_collected(value : int) -> void:
	gears_collected = value
	if gears_collected < 0:
		gears_collected = 0
	if not is_node_ready():
		await ready
	gear_count_label.text = str(gears_collected)
	gear_count_label.scale = Vector2.ONE


func give_equipment(equip_item : CartEquipItem, snap_dir : CartEquipSnapPoint.Direction):
	match snap_dir:
		CartEquipSnapPoint.Direction.FORWARD:
			front_equip.give_attachment_scene(equip_item.equip_scene)
		CartEquipSnapPoint.Direction.LEFT:
			left_equip.give_attachment_scene(equip_item.equip_scene)
		CartEquipSnapPoint.Direction.RIGHT:
			right_equip.give_attachment_scene(equip_item.equip_scene)
		CartEquipSnapPoint.Direction.FORWARD_LEFT:
			front_left_equip.give_attachment_scene(equip_item.equip_scene)
		CartEquipSnapPoint.Direction.FORWARD_RIGHT:
			front_right_equip.give_attachment_scene(equip_item.equip_scene)
		CartEquipSnapPoint.Direction.BACK_LEFT:
			back_left_equip.give_attachment_scene(equip_item.equip_scene)
		CartEquipSnapPoint.Direction.BACK_RIGHT:
			back_right_equip.give_attachment_scene(equip_item.equip_scene)
