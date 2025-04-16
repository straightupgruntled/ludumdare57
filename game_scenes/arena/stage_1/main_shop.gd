@tool
class_name PrizePavilionArena
extends Arena


@export var first_time_dialogue : DialogueMessage


func _ready():
	super()
	DialogueSystem.play_dialogue_message(first_time_dialogue)
