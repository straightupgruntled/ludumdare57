class_name BulletClearBoost
extends Node2D

@onready var clear_particles = $ClearParticles


func _ready():
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.queue_free()
	clear_particles.emitting = true


func _on_clear_particles_finished():
	self.queue_free()
