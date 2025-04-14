class_name CartAttachmentAnchor
extends Node2D

@export var current_attachment : Node2D

@onready var anchor_sprite = $AnchorSprite
@onready var arrow = $Arrow


func _ready():
	arrow.hide()
	anchor_sprite.hide()


func give_attachment_scene(attachment_scene : PackedScene) -> void:
	add_child(attachment_scene.instantiate())
	anchor_sprite.show()


func remove_attachment() -> void:
	if current_attachment:
		current_attachment.queue_free()
		current_attachment = null
		anchor_sprite.hide()
