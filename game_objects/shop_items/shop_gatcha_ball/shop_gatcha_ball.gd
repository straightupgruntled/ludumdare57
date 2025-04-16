@tool
class_name ShopGatchaBall
extends StaticBody2D

enum CurrencyType {
	DIAMOND,
	GEAR
}
@export var currency_type : CurrencyType = CurrencyType.DIAMOND : set = _set_currency_type
@export var shop_item_scene : PackedScene
@export var cost : int = 20 : set = _set_cost
@export var poof_particle_scene : PackedScene
@export var first_heart_full_health_dialogue : DialogueMessage

var current_shop_item : Node
var purchased : bool = false

@onready var diamond_icon = $Sprite2D/DiamondIcon
@onready var gear_icon = $Sprite2D/GearIcon
@onready var cost_label = $CostLabel
@onready var hurtbox = $Hurtbox


func _ready():
	_set_currency_type(currency_type)
	if current_shop_item:
		current_shop_item.queue_free()
	if shop_item_scene:
		current_shop_item = shop_item_scene.instantiate()
		get_parent().add_child.call_deferred(current_shop_item)
		current_shop_item.global_position = global_position
		if current_shop_item is CartEquipCollectable:
			cost = randi_range(5, 9)
		elif current_shop_item is ConsumableCollectable:
			cost = randi_range(18, 28)


func _process(delta):
	if Engine.is_editor_hint():
		return
	scale = scale.lerp(Vector2.ONE, .2)
	if !purchased:
		if currency_type == CurrencyType.DIAMOND:
			hurtbox.active = Global.diamonds >= cost
		elif currency_type == CurrencyType.GEAR:
			hurtbox.active = Global.gears >= cost


func _on_health_component_died():
	if Engine.is_editor_hint():
		return
	purchased = true
	if currency_type == CurrencyType.DIAMOND:
		Global.diamonds -= cost
	elif currency_type == CurrencyType.GEAR:
		Global.gears -= cost
	var poof = poof_particle_scene.instantiate()
	get_parent().add_child.call_deferred(poof)
	poof.global_position = global_position
	if current_shop_item is ConsumableCollectable:
		if current_shop_item.consumable_item.id == 1 and Global.player_health == 6:
			DialogueSystem.play_dialogue_message(first_heart_full_health_dialogue)
	current_shop_item.purchased()
	await get_tree().process_frame
	self.queue_free()


func _set_currency_type(value : CurrencyType) -> void:
	currency_type = value
	if not is_node_ready():
		await ready
	if currency_type == CurrencyType.DIAMOND:
		diamond_icon.show()
		gear_icon.hide()
	elif currency_type == CurrencyType.GEAR:
		gear_icon.show()
		diamond_icon.hide()


func _set_cost(value : int) -> void:
	cost = value
	if not is_node_ready():
		await ready
	cost_label.text = str(cost)


func _on_hurtbox_damage_taken(amount):
	scale = Vector2.ONE * 1.5
