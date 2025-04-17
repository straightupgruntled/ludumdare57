class_name Diamond
extends CharacterBody2D

@export var start_lifetime : float = 14.0

@onready var lifetime : float = start_lifetime

@onready var animation_player = $AnimationPlayer


func _process(delta):
	lifetime -= delta
	if lifetime <= 3.0 and !animation_player.is_playing():
		animation_player.play("flashing")


func _physics_process(delta):
	velocity = velocity.lerp(Vector2.ZERO, .05)
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = collision.get_normal() * velocity.length()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "flashing":
		self.queue_free()
