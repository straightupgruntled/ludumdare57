class_name EnemyBullet
extends CharacterBody2D

@export var damage : int = 5
@export var speed : float = 140.0
@export var poof_particle_scene : PackedScene

var move_dir : Vector2
var bounced : bool = false
var wall_bounced : bool = false

@onready var player_bullet_sprite = $PlayerBulletSprite
@onready var hitbox = $Hitbox


func _ready():
	player_bullet_sprite.hide()
	move_dir = Vector2.RIGHT.rotated(rotation)


func _physics_process(delta):
	velocity = move_dir * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		if !wall_bounced:
			move_dir = move_dir.reflect(collision.get_normal().rotated(PI/2))
			wall_bounced = true
		else:
			impact()
	if wall_bounced:
		scale = scale.move_toward(Vector2(0.6, 0.6), 0.075)


func player_claim() -> void:
	hitbox.type = Hitbox.OwnerType.PLAYER
	hitbox.damage_amount = 4
	player_bullet_sprite.show()
	speed = 300.0


func impact() -> void:
	var poof = poof_particle_scene.instantiate()
	get_parent().add_child(poof)
	poof.global_position = global_position
	self.queue_free()


func _on_hitbox_hit_hurtbox():
	impact()
