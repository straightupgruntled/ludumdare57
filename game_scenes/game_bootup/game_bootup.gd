class_name GameBootup
extends Node

@export var master_volume_boot_scene : PackedScene
@export var title_scene : PackedScene


func _ready():
	await get_tree().process_frame
	if ConfigFileHandler.new_game_launch:
		get_tree().change_scene_to_packed(master_volume_boot_scene)
	else:
		get_tree().change_scene_to_packed(title_scene)
