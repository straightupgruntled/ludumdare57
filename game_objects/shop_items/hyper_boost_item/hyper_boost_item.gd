@tool
class_name HyperBoostItem
extends StaticBody2D

@export var hyper_boost : HyperBoost
@export var diamond_cost : int = 10 : set = _set_diamond_cost
@export var poof_particle_scene : PackedScene

var time : float = 0.0

@onready var sprite = $Sprite2D
@onready var diamond_count_label = $DiamondCountLabel
@onready var active_light = $ActiveLight


func _ready():
	diamond_count_label.text = str(diamond_cost)
	sprite.texture = hyper_boost.icon


func _process(delta):
	time += delta
	$Sprite2D.position.y = sin(time * 5.0) * 2.0
	$Sprite2D.scale = Vector2.ONE * (0.5 + (0.03 * sin(time * 7.0)))
	$Interactable.message = hyper_boost.boost_name


func _on_interactable_interaction_triggered(interactor : Interactor):
	if interactor.owner_body is Player:
		var player : Player = interactor.owner_body
		if Global.diamonds >= diamond_cost:
			EventBus.hyper_boost_item_bought.emit(hyper_boost)
			var poof = poof_particle_scene.instantiate()
			get_parent().call_deferred("add_child", poof)
			poof.global_position = global_position
			Global.diamonds -= diamond_cost
			self.queue_free()
		else:
			active_light.color = Color.RED


func _set_diamond_cost(value : int) -> void:
	diamond_cost = value
	if not is_node_ready():
		await ready
	diamond_count_label.text = str(diamond_cost)


func _on_interactable_entered():
	active_light.color = Color.GREEN


func _on_interactable_exited():
	active_light.color = Color.WHITE
