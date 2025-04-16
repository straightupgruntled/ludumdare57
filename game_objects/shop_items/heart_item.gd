class_name HeartShopCollectable
extends StaticBody2D

signal item_chosen(item_name : String)

@export var item_name : String

var time : float = 0.0

@onready var sprite = $Sprite2D


func _process(delta):
	time += delta
	sprite.position.y = sin(time * 2.0) * 2.0
	sprite.scale = Vector2.ONE * (0.5 + (0.03 * sin(time * 4.0)))
