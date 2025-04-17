@tool
class_name PrizePavilionArena
extends Arena


@export var first_time_dialogue : DialogueMessage


func _ready():
	super()
	if !Engine.is_editor_hint():
		DialogueSystem.play_dialogue_message(first_time_dialogue)
