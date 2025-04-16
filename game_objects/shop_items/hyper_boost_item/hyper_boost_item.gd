@tool
class_name HyperBoostShopCollectable
extends StaticBody2D

@export var hyper_boost_item : HyperBoostItem : set = _set_hyper_boost_item

var time : float = 0.0

@onready var sprite = $Sprite2D
@onready var diamond_count_label = $DiamondCountLabel
@onready var active_light = $ActiveLight


func _ready():
	sprite.texture = hyper_boost_item.icon


func _process(delta):
	time += delta
	sprite.position.y = sin(time * 2.0) * 2.0
	sprite.scale = Vector2.ONE * (0.5 + (0.02 * sin(time * 4.0)))
