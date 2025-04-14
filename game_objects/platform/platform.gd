class_name Platform
extends StaticBody2D

signal player_entered
signal cart_check_complete
signal entrance_complete
signal descent_started
signal descent_ended

enum State {
	ENTERING,
	LOCKED_IN,
	EXITING
}
@export var current_state : State = State.ENTERING
@export var diamond_requirement : int = 2 : set = _set_diamond_requirement
@export var follow_camera : FollowCamera
@export var player : Player
@export var cart : Cart
@export var object_root : Node2D
@export var target_light_color : Color

var near_player : Player
var near_cart : Cart
var cart_locked : bool = false
var cart_checked : bool = false

@onready var sprite = $Sprite2D
@onready var fixed_pivot = $Sprite2D/FixedPivot
@onready var lock_poof = $LockPoof
@onready var weight_light = $WeightLight
@onready var diamond_count_label = $Sprite2D/FixedPivot/DiamondCountLabel
@onready var railing_sprite = $RailingSprite
@onready var weight_timer = $WeightTimer
@onready var continue_interactable = $ContinueInteractable
@onready var animation_player = $AnimationPlayer

#SFX#
@onready var descent_sfx = $DescentSFX
@onready var lock_in_sfx = $LockInSFX


func _ready():
	if current_state == State.ENTERING:
		player.reparent.call_deferred(sprite)
		cart.reparent.call_deferred(sprite)
		start_entrance()
	elif current_state == State.LOCKED_IN:
		player.freeze()
		for i in 2:
			await get_tree().physics_frame
		lock_in_to_arena()


func _physics_process(delta):
	railing_sprite.global_scale = Vector2.ONE
	weight_light.color = weight_light.color.lerp(target_light_color, .3)
	fixed_pivot.visible = diamond_requirement > 0
	match current_state:
		State.ENTERING:
			scale = scale.move_toward(Vector2.ONE, .01)
			follow_camera.zoom = follow_camera.zoom.move_toward(Vector2.ONE * 1.6, 0.006)
			if scale == Vector2.ONE:
				lock_in_to_arena()
		State.EXITING:
			scale *= .993
			follow_camera.zoom *= 1.0025
			if scale.x < 0.2:
				finish_exit()
	if near_cart:
		if near_cart.current_move_mode == Cart.MoveMode.FREE and !cart_checked:
			lock_cart()
		elif cart_locked:
			cart.global_position = cart.global_position.lerp(global_position, .1)


func start_entrance() -> void:
	player.freeze()
	animation_player.play("rumble")
	current_state = State.ENTERING
	z_index = 2
	player.hurtbox.active = false
	scale = Vector2.ONE * 2.0
	follow_camera.zoom = Vector2.ONE * 0.9
	target_light_color = Color.WHITE
	weight_light.energy = 0.0
	if !descent_sfx.playing:
		descent_sfx.play()
	await get_tree().process_frame


func lock_in_to_arena() -> void:
	animation_player.stop()
	animation_player.play("RESET")
	current_state = State.LOCKED_IN
	z_index = -2
	lock_poof.emitting = true
	descent_sfx.stop()
	lock_in_sfx.play()
	follow_camera.apply_shake()
	player.reparent.call_deferred(object_root)
	cart.reparent.call_deferred(object_root)
	entrance_complete.emit()
	cart_checked = true
	if diamond_requirement > 0:
		target_light_color = Color.RED
		weight_light.color = target_light_color
		weight_light.energy = 1.0
		cart.unlock_from_platform()
		cart.release_player()
		cart_locked = false
	player.unfreeze()
	player.hurtbox.active = true
	player.flashlight.show()
	follow_camera.target_node = player
	if diamond_requirement == 0:
		continue_interactable.active = true


func lock_cart() -> void:
	target_light_color = Color.WHITE
	cart.release_player()
	cart.lock_to_platform()
	cart_locked = true
	weight_timer.start()


func attempt_descent() -> void:
	cart_checked = true
	if near_cart:
		if near_cart.diamonds_collected >= diamond_requirement:
			target_light_color = Color.GREEN
			continue_interactable.active = true
		else:
			target_light_color = Color.RED
			cart.unlock_from_platform()
			cart_locked = false
	cart_check_complete.emit()


func start_exit() -> void:
	if !near_player and !cart.player_ref:
		await player_entered
	z_index = -2
	follow_camera.apply_shake_small()
	animation_player.play("rumble")
	current_state = State.EXITING
	descent_started.emit()
	player.freeze()
	player.hurtbox.active = false
	player.flashlight.hide()
	player.reparent.call_deferred(sprite)
	cart.reparent.call_deferred(sprite)
	follow_camera.target_node = cart
	descent_sfx.play()


func finish_exit() -> void:
	follow_camera.zoom = Vector2.ONE * 0.9
	player.freeze()
	player.hurtbox.active = false
	Global.diamonds += cart.diamonds_collected
	Global.gears += cart.gears_collected
	cart.diamonds_collected = 0
	cart.gears_collected = 0
	target_light_color = Color.WHITE
	descent_ended.emit()
	scale = Vector2.ONE * 2.0
	start_entrance()


func _on_object_detector_body_entered(body):
	if current_state != State.LOCKED_IN:
		return
	if body is Cart:
		near_cart = body


func _on_object_detector_body_exited(body):
	if body == near_cart:
		if current_state == State.LOCKED_IN:
			target_light_color = Color.WHITE
		cart_checked = false
		near_cart = null


func _on_player_detector_body_entered(body):
	if body is Player:
		near_player = body
		player_entered.emit()


func _on_player_detector_body_exited(body):
	if body == near_player:
		near_player = null


func _set_diamond_requirement(value : int) -> void:
	diamond_requirement = value
	if not is_node_ready():
		await ready
	diamond_count_label.text = str(diamond_requirement)


func _on_interactable_interaction_triggered(interactor):
	continue_interactable.active = false
	start_exit()
