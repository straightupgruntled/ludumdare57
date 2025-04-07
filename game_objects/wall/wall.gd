extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D

#SFX#
@onready var descent_sfx = $DescentSFX
@onready var lock_in_sfx = $LockInSFX


func trigger() -> void:
	descent_sfx.play()
	animation_player.play("lower_wall")
	await get_tree().create_timer(1.0).timeout
	descent_sfx.stop()
	lock_in_sfx.play()
	collision_shape.set_deferred("disabled", true)
