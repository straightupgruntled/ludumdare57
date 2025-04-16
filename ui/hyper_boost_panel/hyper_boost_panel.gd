class_name HyperBoostItemPanel
extends Control

signal hyper_boost_used(hyper_boost : HyperBoostItem)

@export var player : Player : set = _set_player

@onready var slots = $Slots


func _ready():
	EventBus.hyper_boost_item_bought.connect(obtain_hyper_boost)
	for slot in slots.get_children():
		if slot is HyperBoostItemSlot:
			slot.boost_used.connect(_on_hyper_boost_slot_used)


func obtain_hyper_boost(hyper_boost : HyperBoostItem) -> void:
	var target_slot : HyperBoostItemSlot
	for slot in slots.get_children():
		if slot is HyperBoostItemSlot:
			if !slot.hyper_boost:
				target_slot = slot
				break
	if target_slot:
		target_slot.hyper_boost = hyper_boost


func _set_player(value : Player) -> void:
	player = value
	if player:
		hyper_boost_used.connect(player.use_hyper_boost)


func _on_hyper_boost_slot_used(hyper_boost : HyperBoostItem) -> void:
	hyper_boost_used.emit(hyper_boost)
