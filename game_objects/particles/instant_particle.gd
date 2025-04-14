class_name InstantParticles
extends GPUParticles2D


func _ready():
	emitting = true


func _on_finished():
	self.queue_free()
