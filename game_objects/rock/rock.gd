class_name Rock
extends StaticBody2D

@export var diamond_scene : PackedScene

@onready var animation_player = $AnimationPlayer

func _ready():
	rotation = randf_range(-PI, PI)
	scale = Vector2.ZERO


func _physics_process(delta):
	scale = scale.lerp(Vector2.ONE, .025)


func health_lost(new_health : int) -> void:
	animation_player.stop()
	animation_player.play("hit")


func create_diamond() -> void:
	var diamond : Diamond = diamond_scene.instantiate()
	get_parent().call_deferred("add_child", diamond)
	diamond.global_position = global_position
	diamond.rotation = randf_range(0.0, 2*PI)
	diamond.velocity = Vector2.RIGHT.rotated(randf_range(0.0, 2*PI)) * 200.0


func _on_health_component_died():
	for i in randi_range(4, 10):
		create_diamond()
	self.queue_free()
