class_name HyperBoostPanel
extends Control

signal hyper_boost_used(hyper_boost : HyperBoost)

@export var player : Player : set = _set_player

@onready var slots = $Slots


func _ready():
	EventBus.hyper_boost_item_bought.connect(obtain_hyper_boost)
	for slot in slots.get_children():
		if slot is HyperBoostSlot:
			slot.boost_used.connect(_on_hyper_boost_slot_used)


func obtain_hyper_boost(hyper_boost : HyperBoost) -> void:
	var target_slot : HyperBoostSlot
	for slot in slots.get_children():
		if slot is HyperBoostSlot:
			if !slot.hyper_boost:
				target_slot = slot
				break
	if target_slot:
		target_slot.hyper_boost = hyper_boost


func _set_player(value : Player) -> void:
	player = value
	if player:
		hyper_boost_used.connect(player.use_hyper_boost)


func _on_hyper_boost_slot_used(hyper_boost : HyperBoost) -> void:
	hyper_boost_used.emit(hyper_boost)
