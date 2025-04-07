class_name FollowCamera
extends Camera2D

@export var target_node : Node2D
@export var descending : bool = false
@export var random_strength : float = 100.0
@export var shake_fade : float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength : float = 0.0
var shake_offset : Vector2


func _ready():
	if target_node:
		global_position = target_node.global_position


func _physics_process(delta):
	if !target_node:
		return
	if target_node:
		var look_offset : Vector2
		if InputMode.is_keyboard():
			look_offset = (get_global_mouse_position() - target_node.global_position) / 8.0
		elif InputMode.is_gamepad():
			var aim_vector := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
			if aim_vector.length_squared() > 0.0:
				look_offset = aim_vector * 22.0
		var target_pos := target_node.global_position + look_offset + shake_offset
		position = position.lerp(round(target_pos), .25)
		if descending:
			zoom *= 1.0035
	

func _process(delta):
	if shake_strength > 0.0:
		shake_strength = lerpf(shake_strength, 0.0, shake_fade * delta)
		shake_offset = random_offset()


func apply_shake() -> void:
	shake_strength = random_strength


func apply_shake_small() -> void:
	shake_strength = random_strength/4.0


func random_offset() -> Vector2:
	var rand_off = Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	return round(rand_off)
