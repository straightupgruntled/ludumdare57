class_name Diamond
extends CharacterBody2D


func _physics_process(delta):
	velocity = velocity.lerp(Vector2.ZERO, .05)
	move_and_slide()
