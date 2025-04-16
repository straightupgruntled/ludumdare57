class_name Platform
extends StaticBody2D

signal entrance_complete
signal descent_started
signal descent_ended

enum State {
	ENTERING,
	LOCKED_INTO_ARENA,
	EXITING
}
@export var current_state : State = State.ENTERING

@export var diamond_requirement : int = 2 : set = _set_diamond_requirement
@export var follow_camera : FollowCamera
@export var player : Player
@export var cart : Cart
@export var object_root : Node2D
@export var descent_dialogue : DialogueMessage

static var has_descended : bool = false
var is_cart_near : bool = false
var target_light_color : Color

@onready var lock_poof = $LockPoof
@onready var sprite = $Sprite2D
@onready var fixed_pivot = $Sprite2D/FixedPivot
@onready var diamond_count_label = $Sprite2D/FixedPivot/DiamondCountLabel
@onready var weight_light = $WeightLight
@onready var railing_sprite = $RailingSprite
@onready var weight_timer = $WeightTimer
@onready var descent_area = $DescentArea
@onready var animation_player = $AnimationPlayer

#SFX#
@onready var descent_sfx = $DescentSFX
@onready var lock_in_sfx = $LockInSFX


func _ready():
	has_descended = false
	if current_state == State.ENTERING:
		start_entrance()
	elif current_state == State.LOCKED_INTO_ARENA:
		lock_in_to_arena()


func _physics_process(delta):
	railing_sprite.global_scale = Vector2.ONE
	weight_light.color = weight_light.color.lerp(target_light_color, .15)
	match current_state:
		State.ENTERING:
			scale = scale.move_toward(Vector2.ONE, .01)
			follow_camera.zoom = follow_camera.zoom.move_toward(Vector2.ONE * 1.6, 0.006)
			if scale == Vector2.ONE:
				lock_in_to_arena()
		State.LOCKED_INTO_ARENA:
			check_descent_conditions()
		State.EXITING:
			scale *= .993
			follow_camera.zoom *= 1.0025
			if scale.x < 0.2:
				finish_exit()


func start_entrance() -> void:
	current_state = State.ENTERING
	player.freeze()
	cart.freeze()
	player.reparent.call_deferred(sprite)
	cart.reparent.call_deferred(sprite)
	player.flashlight.hide()
	follow_camera.zoom = Vector2.ONE * 0.9
	scale = Vector2.ONE * 2.0
	weight_light.energy = 0.0
	z_index = 2
	if !descent_sfx.playing:
		descent_sfx.play()


func lock_in_to_arena() -> void:
	current_state = State.LOCKED_INTO_ARENA
	player.reparent.call_deferred(object_root)
	cart.reparent.call_deferred(object_root)
	z_index = -2
	animation_player.stop()
	animation_player.play("RESET")
	lock_poof.emitting = true
	descent_sfx.stop()
	lock_in_sfx.play()
	follow_camera.apply_shake()
	entrance_complete.emit()
	follow_camera.target_node = player
	if diamond_requirement == 0:
		descent_area.active = true
	await get_tree().process_frame
	cart.unfreeze()
	if !cart.player_ref:
		player.unfreeze()
	else:
		cart.player_grab_cart(cart.player_ref)
	player.hurtbox.active = true
	check_descent_conditions()
	weight_light.color = target_light_color
	weight_light.energy = 1.0


func check_descent_conditions() -> void:
	if is_cart_near and cart.diamonds_collected >= diamond_requirement:
		target_light_color = Color.GREEN
		descent_area.active = true
	else:
		target_light_color = Color.RED
		descent_area.active = false


func start_exit() -> void:
	descent_area.active = false
	current_state = State.EXITING
	player.freeze()
	player.hurtbox.active = false
	cart.freeze()
	player.reparent.call_deferred(sprite)
	cart.reparent.call_deferred(sprite)
	player.flashlight.hide()
	follow_camera.target_node = cart
	z_index = -2
	follow_camera.apply_shake_small()
	animation_player.play("rumble")
	weight_light.energy = 0.0
	descent_sfx.play()
	descent_started.emit()
	if !has_descended:
		DialogueSystem.play_dialogue_message(descent_dialogue)
		has_descended = true


func finish_exit() -> void:
	follow_camera.zoom = Vector2.ONE * 0.9
	cash_in_diamonds_and_gears()
	scale = Vector2.ONE * 2.0
	descent_ended.emit()
	start_entrance()


func cash_in_diamonds_and_gears() -> void:
	Global.diamonds += cart.diamonds_collected
	Global.gears += cart.gears_collected
	cart.diamonds_collected = 0
	cart.gears_collected = 0


func _on_object_detector_body_entered(body):
	if body is Cart:
		is_cart_near = true


func _on_object_detector_body_exited(body):
	if body is Cart:
		is_cart_near = false


func _on_interactable_interaction_triggered(interactor):
	start_exit()


func _set_diamond_requirement(value : int) -> void:
	diamond_requirement = value
	Global.diamond_requirement = diamond_requirement
	if not is_node_ready():
		await ready
	diamond_count_label.text = str(diamond_requirement)
	fixed_pivot.visible = diamond_requirement > 0
