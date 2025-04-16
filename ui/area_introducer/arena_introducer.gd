class_name ArenaIntroducer
extends Control

@onready var floor_text = $FloorText
@onready var animation_player = $AnimationPlayer


func introduce_floor(floor_display : String) -> void:
	animation_player.stop()
	floor_text.text = "[shake rate=6 level=30 connected=0]" + floor_display + "[/shake]"
	animation_player.play("introduction")
