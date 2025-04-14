extends Node2D

@onready var animation_player = $AnimationPlayer


func _ready():
	modulate.a = 0.0


func trigger() -> void:
	if !animation_player.is_playing():
		animation_player.play("pulse")
