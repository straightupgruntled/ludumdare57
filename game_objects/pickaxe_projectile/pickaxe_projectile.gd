class_name PickaxeProjectile
extends CharacterBody2D

@export var max_bounces : int = 2
@export var speed : float = 900.0
@export var return_speed : float = 450.0

var player_ref : Player
var throw_dir : Vector2
var bounce_count : int = 0
var returning : bool = false

#SFX#
@onready var bounce_sfx = $BounceSFX
@onready var impact_sfx = $ImpactSFX



func _physics_process(delta):
	if !returning:
		rotation += 8 * PI * delta
		velocity = throw_dir * speed
	else:
		var distance_to_player = (player_ref.global_position - global_position).length()
		if distance_to_player < 10.0:
			player_ref.return_pickaxe(self)
		elif distance_to_player < 100.0:
			scale = scale.lerp(Vector2.ONE, .2)
		else:
			scale = scale.lerp(Vector2.ONE * 1.75, .1)
		rotation -= 4 * PI * delta
		var to_player_dir = (player_ref.global_position - global_position).normalized()
		velocity = to_player_dir * return_speed
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		bounce_count += 1
		bounce_sfx.pitch_scale = randf_range(0.9, 1.1)
		bounce_sfx.play()
		if bounce_count >= max_bounces:
			return_to_player()
		else:
			throw_dir = throw_dir.reflect(collision.get_normal().rotated(PI/2))
			move_and_collide(velocity * delta)


func return_to_player() -> void:
	bounce_count = max_bounces
	throw_dir = Vector2.ZERO
	velocity = Vector2.ZERO
	set_collision_mask_value(1, false)
	set_collision_mask_value(4, false)
	returning = true


func _on_hitbox_hit_hurtbox():
	impact_sfx.pitch_scale = randf_range(0.9, 1.1)
	impact_sfx.play()
