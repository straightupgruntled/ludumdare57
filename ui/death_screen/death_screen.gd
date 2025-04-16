extends Control

var floors_cleared : int = 0

@onready var animation_player = $AnimationPlayer
@onready var floors_cleared_text = $FloorsClearedText

@export var death_1 : DialogueMessage
@export var death_2 : DialogueMessage
@export var death_3 : DialogueMessage


func trigger_game_over() -> void:
	show()
	animation_player.play("start_game_over")
	floors_cleared_text.text = "Floors Cleared: " + str(floors_cleared)
	var chance = randi_range(0, 10)
	if chance < 3:
		DialogueSystem.play_dialogue_message(death_1)
	elif chance < 6:
		DialogueSystem.play_dialogue_message(death_2)
	else:
		DialogueSystem.play_dialogue_message(death_3)
	await DialogueSystem.finished
	TransitionManager.transition_to_file_scene(get_tree().current_scene.scene_file_path)
