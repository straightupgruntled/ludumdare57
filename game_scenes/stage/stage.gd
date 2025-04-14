class_name Stage
extends Node2D

@export var arena_collections : Array[ArenaCollection]
@export var current_level : int = 0
@export var platform : NewPlatform

var current_arena_scene : PackedScene
var current_arena : Arena
var floor_step_counter : int = 0
var floors_cleared : int = 0
var total_requirement : int = 10

@onready var arena_holder = $ArenaHolder
@onready var animation_player = $ScreenTransition/AnimationPlayer
@onready var hud = $HUD
@onready var back_parallax = $BackParallax
@onready var front_parallax = $FrontParallax


func _ready():
	Global.diamonds = 0
	Global.gears = 0
	TransitionManager.music_pitch = 1.0
	TransitionManager.start_music()
	load_next_arena()


func _input(event):
	if event.is_action_pressed("reroll_arena"):
		load_next_arena()


func load_next_arena() -> void:
	if floor_step_counter == 2:
		current_level += 1
		TransitionManager.music_pitch = 0.8
	elif floor_step_counter == 3:
		current_level = 0
		floor_step_counter = 0
		TransitionManager.music_pitch = 1.0
	for child in get_children():
		if child.is_in_group("clearable"):
			child.queue_free()
	var chosen_arena_collection : ArenaCollection = arena_collections[current_level]
	if current_arena:
		current_arena.queue_free()
		current_arena = null
	var chosen_arena_scene : PackedScene = current_arena_scene
	while chosen_arena_scene == current_arena_scene:
		current_arena_scene = chosen_arena_collection.pick_random_arena_scene()
	current_arena = current_arena_scene.instantiate()
	arena_holder.call_deferred("add_child", current_arena)
	await get_tree().process_frame
	set_parallax_color(current_arena.background_modulate)
	if current_arena.safe_arena:
		platform.diamond_requirement = 0
	else:
		platform.diamond_requirement = total_requirement


func _on_platform_descent_ended():
	total_requirement += 5
	floors_cleared += 1
	floor_step_counter += 1
	load_next_arena()
	hud.death_screen.floors_cleared = floors_cleared
	animation_player.play("fade_into_scene")


func _on_platform_descent_started():
	await get_tree().create_timer(2.5).timeout
	animation_player.play("fade_out_scene")


func set_parallax_color(new_modulate : Color) -> void:
	if not is_node_ready():
		await ready
	for child in back_parallax.get_children():
		child.modulate = new_modulate
	for child in front_parallax.get_children():
		child.modulate = new_modulate
