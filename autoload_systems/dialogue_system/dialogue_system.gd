extends CanvasLayer

signal finished

@onready var text_dialogue = $TextDialogue
@onready var audio_dialogue_player = $AudioDialoguePlayer

var current_dialogue_message : DialogueMessage
var current_line : int = 0


func play_dialogue_message(dialogue_message : DialogueMessage) -> void:
	current_line = 0
	current_dialogue_message = dialogue_message
	audio_dialogue_player.stop()
	audio_dialogue_player.stream = current_dialogue_message.dialogue_audio_stream
	audio_dialogue_player.play()
	text_dialogue.show()
	text_dialogue.text = current_dialogue_message.text_lines[current_line]


func stop_dialogue() -> void:
	if audio_dialogue_player.is_playing():
		audio_dialogue_player.stop()
		text_dialogue.hide()
		current_dialogue_message = null
		finished.emit()


func is_playing() -> bool:
	return is_instance_valid(current_dialogue_message)


func _process(delta):
	if current_dialogue_message:
		if audio_dialogue_player.get_playback_position() > current_dialogue_message.textline_split_times[current_line]:
			current_line += 1
			if current_line == current_dialogue_message.text_lines.size():
				text_dialogue.hide()
				current_dialogue_message = null
				finished.emit()
			else:
				text_dialogue.text = current_dialogue_message.text_lines[current_line]
