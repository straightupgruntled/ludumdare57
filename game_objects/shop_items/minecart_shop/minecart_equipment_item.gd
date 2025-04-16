class_name CartEquipCollectable
extends StaticBody2D

@export var cart_equip_item : CartEquipItem : set = _set_cart_equip_item
@export var cart_equip_item_choices : Array[CartEquipItem]

var time : float = 0.0

@onready var sprite = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var buy_sfx = $BuySFX


func _ready():
	if Engine.is_editor_hint():
		return
	if !cart_equip_item:
		cart_equip_item = cart_equip_item_choices.pick_random()


func _process(delta):
	time += delta
	sprite.position.y = sin(time * 5.0) * 2.0
	sprite.scale = Vector2.ONE * (1.2 + (0.07 * sin(time * 7.0)))


func purchased() -> void:
	collision_shape.set_deferred("disabled", false)
	buy_sfx.play()


func _set_cart_equip_item(value : CartEquipItem) -> void:
	cart_equip_item = value
	if not is_node_ready():
		await ready
	sprite.texture = cart_equip_item.icon
