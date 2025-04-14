class_name ArenaCollection
extends Resource

@export_file() var arena_scene_files : Array[String]


func pick_random_arena_scene() -> PackedScene:
	var arena_scene_file = arena_scene_files.pick_random()
	var arena_scene = load(arena_scene_file)
	return arena_scene
