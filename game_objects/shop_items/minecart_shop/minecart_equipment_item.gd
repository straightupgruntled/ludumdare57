class_name MinecartEquipmentItem
extends StaticBody2D

@export var equipment_item : MinecartEquipment
@export var gear_cost : int = 10 : set = _set_gear_cost
@export var poof_particle_scene : PackedScene

var time : float = 0.0

@onready var sprite = $Sprite2D
@onready var gear_count_label = $GearCountLabel
@onready var active_light = $ActiveLight


func _ready():
	gear_count_label.text = str(gear_cost)
	sprite.texture = equipment_item.icon


func _process(delta):
	time += delta
	$Sprite2D.position.y = sin(time * 5.0) * 2.0
	$Sprite2D.scale = Vector2.ONE * (1.15 + (0.07 * sin(time * 7.0)))
	$Interactable.message = equipment_item.equipment_name


func _on_interactable_interaction_triggered(interactor : Interactor):
	if interactor.owner_body is Player:
		var player : Player = interactor.owner_body
		if Global.gears >= gear_cost:
			EventBus.minecart_equipment_item_bought.emit(equipment_item)
			var poof = poof_particle_scene.instantiate()
			get_parent().call_deferred("add_child", poof)
			poof.global_position = global_position
			Global.gears -= gear_cost
			self.queue_free()
		else:
			active_light.color = Color.RED


func _set_gear_cost(value : int) -> void:
	gear_cost = value
	if not is_node_ready():
		await ready
	gear_count_label.text = str(gear_cost)


func _on_interactable_entered():
	active_light.color = Color.GREEN


func _on_interactable_exited():
	active_light.color = Color.WHITE
