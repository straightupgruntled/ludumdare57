class_name FollowCamera
extends Camera2D

@export var target_node : Node2D : set = _set_target_node
@export var random_strength : float = 100.0
@export var shake_fade : float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength : float = 0.0
var shake_offset : Vector2
var rotate_x : float = 0.003


func _ready():
	if target_node:
		global_position = target_node.global_position


func _physics_process(delta):
	if !target_node:
		return
	var look_offset : Vector2
	if Global.aim_following_active:
		if InputMode.is_keyboard():
			var aim_vector = (get_global_mouse_position() - target_node.global_position) / 6.0
			if aim_vector.length_squared() > 0.0:
				look_offset = round(aim_vector)
		elif InputMode.is_gamepad():
			var aim_vector := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
			if aim_vector.length_squared() > 0.0:
				look_offset = round(aim_vector * 28.0)
	
	if shake_strength > 0.0 and Global.screenshake_active:
		shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
		shake_offset = random_offset()
	else:
		shake_offset = Vector2.ZERO
	
	var target_pos = target_node.global_position + look_offset + shake_offset
	position = position.lerp(round(target_pos), .25)
	if target_node is CharacterBody2D and Global.camera_rotation_active:
		rotation_degrees = -target_node.velocity.x * rotate_x
	else:
		rotation_degrees = 0.0


func apply_shake() -> void:
	shake_strength = random_strength


func apply_shake_small() -> void:
	shake_strength = random_strength / 4.0


func random_offset() -> Vector2:
	var rand_off = Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	return round(rand_off)


func _set_target_node(value : Node2D) -> void:
	target_node = value
	if not is_node_ready():
		await ready
	if target_node:
		set_physics_process(true)
	else:
		set_physics_process(false)
	if target_node is Cart:
		rotate_x = 0.001
	elif target_node is Player:
		rotate_x = 0.0000
	else:
		rotate_x = 0.0
