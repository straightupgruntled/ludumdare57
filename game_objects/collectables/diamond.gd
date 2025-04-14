class_name Diamond
extends CharacterBody2D

@onready var animation_player = $AnimationPlayer


func _ready():
	await get_tree().create_timer(8.0).timeout
	animation_player.play("flashing")
	await get_tree().create_timer(3.0).timeout
	self.queue_free()


func _physics_process(delta):
	velocity = velocity.lerp(Vector2.ZERO, .05)
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = collision.get_normal() * velocity.length()
