extends StaticBody2D

@export var dropped : bool = false


@onready var animation_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D
@onready var up_sprite = $UpSprite

#SFX#
@onready var descent_sfx = $DescentSFX
@onready var lock_in_sfx = $LockInSFX


func _ready():
	if dropped:
		collision_shape.set_deferred("disabled", true)
		scale = Vector2.ONE
		up_sprite.modulate.a = 0.0
		z_index = -1
	else:
		collision_shape.set_deferred("disabled", false)
		scale = Vector2(1.25, 1.25)
		up_sprite.modulate.a = 1.0
		z_index = 1


func lower() -> void:
	descent_sfx.play()
	animation_player.play("lower_wall")
	await get_tree().create_timer(1.0).timeout
	dropped = true
	descent_sfx.stop()
	lock_in_sfx.play()
	collision_shape.set_deferred("disabled", true)
	z_index = -1


func raise() -> void:
	descent_sfx.play()
	animation_player.play("raise_wall")
	collision_shape.set_deferred("disabled", false)
	z_index = 1
	await get_tree().create_timer(1.0).timeout
	dropped = false
	descent_sfx.stop()
	lock_in_sfx.play()
