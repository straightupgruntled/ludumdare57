extends Control

signal finished

@onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	if Global.intro_completed:
		self.queue_free()
	await get_tree().create_timer(0.5).timeout
	animation_player.play("intro")


func _input(event):
	if event.is_action_pressed("skip_intro") and !Global.intro_completed:
		animation_player.seek(7.0)
		animation_player.stop()
		finished.emit()
		Global.intro_completed = true
		self.queue_free()


func _on_animation_player_animation_finished(anim_name):
	finished.emit()
	Global.intro_completed = true
	self.queue_free()
