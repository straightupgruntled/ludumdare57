class_name PickaxeShopCollectable
extends StaticBody2D

signal item_chosen(item_name : String)

@export var item_name : String

var time : float = 0.0

@onready var sprite = $Sprite2D


func _process(delta):
	time += delta
	sprite.position.y = sin(time * 5.0) * 2.0
	sprite.scale = Vector2.ONE * (0.9 + (0.07 * sin(time * 7.0)))
