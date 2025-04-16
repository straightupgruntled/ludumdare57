@tool
class_name HubRoom
extends Arena

static var first_time : bool = false

@export var start_dialogue : DialogueMessage


func _ready():
	super()
	if first_time:
		DialogueSystem.play_dialogue_message(start_dialogue)
		first_time = false
