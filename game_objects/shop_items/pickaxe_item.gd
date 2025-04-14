class_name PickaxeItem
extends StaticBody2D

signal item_chosen(item_name : String)

@export var item_name : String
@export var diamond_cost : int = 10 : set = _set_diamond_cost
@export var poof_particle_scene : PackedScene

var time : float = 0.0

@onready var diamond_count_label = $DiamondCountLabel
@onready var active_light = $ActiveLight


func _ready():
	diamond_count_label.text = str(diamond_cost)


func _process(delta):
	time += delta
	$Sprite2D.position.y = sin(time * 5.0) * 2.0
	$Sprite2D.scale = Vector2.ONE * (1.7 + (0.14 * sin(time * 7.0)))


func _on_interactable_interaction_triggered(interactor : Interactor):
	if interactor.owner_body is Player:
		var player : Player = interactor.owner_body
		if Global.diamonds >= diamond_cost and player.max_picks < 5:
			item_chosen.emit(item_name)
			var poof = poof_particle_scene.instantiate()
			get_parent().call_deferred("add_child", poof)
			poof.global_position = global_position
			Global.diamonds -= diamond_cost
			player.picks_to_throw += 1
			player.max_picks += 1
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
