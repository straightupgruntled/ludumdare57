@tool
class_name ConsumableCollectable
extends StaticBody2D

@export var consumable_item : ConsumableItem : set = _set_consumable_item
@export var consumable_item_choices : Array[ConsumableItem]

var time : float = 0.0

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var buy_sfx = $BuySFX



func _ready():
	if Engine.is_editor_hint():
		return
	if !consumable_item:
		consumable_item = consumable_item_choices.pick_random()


func _process(delta):
	time += delta
	sprite.position.y = sin(time * 5.0) * 2.0
	sprite.scale = Vector2.ONE * (0.9 + (0.07 * sin(time * 7.0)))


func purchased() -> void:
	collision_shape.set_deferred("disabled", false)
	buy_sfx.play()


func _set_consumable_item(value : ConsumableItem) -> void:
	consumable_item = value
	if not is_node_ready():
		await ready
	sprite.texture = consumable_item.icon
