class_name Platform
extends StaticBody2D

signal entrance_complete(platform : Platform)
signal descent_started(platform : Platform)

@export var diamond_requirement : int = 2
@export var near_player : Player
@export var near_cart : Cart
@export var raised_on_start : bool = true

var cart_claimed : Cart
var cart_checked : bool = false
var descending : bool = false
var entering : bool = true

@onready var weight_light = $WeightLight
@onready var weight_check_timer = $WeightCheckTimer
@onready var diamond_count_label = $FixedPivot/DiamondCountLabel

#SFX#
@onready var descent_sfx = $DescentSFX
@onready var lock_in_sfx = $LockInSFX


func _ready():
	if raised_on_start:
		descent_sfx.play()
		scale = Vector2.ONE * 2.0
	else:
		entering = false
		z_index = 0
		scale = Vector2.ONE
		entrance_complete.emit(self)
	diamond_count_label.text = str(diamond_requirement)


func _physics_process(delta):
	if entering:
		z_index = 1
		scale = scale.move_toward(Vector2.ONE, .01)
		if (scale.x - 1.0) < 0.01:
			entering = false
			descent_sfx.stop()
			z_index = 0
			scale = Vector2.ONE
			lock_in_sfx.play()
			entrance_complete.emit(self)
	if near_cart:
		weight_light.energy = lerpf(weight_light.energy, 1.0, 0.075)
		if cart_claimed:
			near_cart.global_position = global_position
			near_cart.velocity = Vector2.ZERO
		elif !cart_checked:
			near_cart.global_position = near_cart.global_position.lerp(global_position, 0.05)
	else:
		weight_light.energy = lerpf(weight_light.energy, 0.0, 0.1)
	if descending:
		scale *= .9925


func _on_weight_check_timer_timeout():
	if near_cart and !descending:
		if near_cart.diamonds_collected >= diamond_requirement:
			weight_light.color = Color.GREEN
			cart_claimed = near_cart
			cart_claimed.frozen = true
			await get_tree().create_timer(1.0).timeout
			cart_claimed.reparent(self)
			if near_player:
				near_player.reparent(self)
			descending = true
			descent_started.emit(self)
			descent_sfx.play()
		else:
			weight_light.color = Color.RED
			near_cart.unlock_from_platform()
			cart_checked = true


func _on_object_detector_body_entered(body):
	if body is Player:
		near_player = body
	elif body is Cart:
		if entering:
			await entrance_complete
		near_cart = body
		weight_light.color = Color.WHITE
		near_cart.lock_to_platform()
		weight_check_timer.stop()
		weight_check_timer.start()


func _on_object_detector_body_exited(body):
	if body == near_player:
		near_player = null
	elif body == near_cart:
		near_cart = null
		cart_checked = false
