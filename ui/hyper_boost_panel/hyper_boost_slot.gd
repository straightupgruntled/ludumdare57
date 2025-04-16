@tool
class_name HyperBoostItemSlot
extends Control

signal boost_used(hyper_boost : HyperBoostItem)

const BASE_EVENT_NAME = "hyper_boost_"

@export var slot_number : int = 1 : set = _set_slot_number
@export var hyper_boost : HyperBoostItem : set = _set_hyper_boost

@onready var backing = $Backing
@onready var backing_used = $BackingUsed
@onready var icon = $Icon
@onready var prompt = $Prompt


func _ready():
	backing_used.hide()


func _input(event):
	if event.is_action_pressed(BASE_EVENT_NAME + str(slot_number)) and hyper_boost:
		boost_used.emit(hyper_boost)
		backing.scale = Vector2.ONE * 1.43
		backing_used.scale = Vector2.ONE * 1.43
		hyper_boost = null
		backing_used.show()
		await get_tree().create_timer(.1).timeout
		backing_used.hide()


func _process(delta):
	if not Engine.is_editor_hint():
		backing.scale = backing.scale.lerp(Vector2.ONE, Global.lerp_factor(12.0, delta))
		backing_used.scale = backing.scale.lerp(Vector2.ONE, Global.lerp_factor(12.0, delta))


func _set_slot_number(value : int) -> void:
	slot_number = value
	if not is_node_ready():
		await ready
	prompt.text = str(slot_number)
	if not Engine.is_editor_hint():
		backing.scale = Vector2.ONE * 1.43


func _set_hyper_boost(value : HyperBoostItem) -> void:
	hyper_boost = value
	if not is_node_ready():
		await ready
	if hyper_boost:
		icon.texture = hyper_boost.icon
	else:
		icon.texture = null
