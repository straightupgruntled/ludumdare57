class_name DescentArea
extends Area2D

signal triggered

@export var message : String
@export var active : bool = true : set = _set_active

var player_ref : Player
var target_modulate : float = 0.0

@onready var tooltip_label = $TooltipLabel


func _ready():
	InputMode.input_type_changed.connect(_input_mode_changed)
	_input_mode_changed()
	tooltip_label.modulate.a = 0.0


func _input(event):
	if active and player_ref:
		if event.is_action_pressed("continue_descent"):
			trigger()


func _process(delta):
	global_rotation = 0.0
	tooltip_label.modulate.a = lerpf(tooltip_label.modulate.a, target_modulate, Global.lerp_factor(50.0, delta))
	if player_ref and active:
		show_interaction()
	else:
		hide_interaction()


func show_interaction() -> void:
	target_modulate = 1.0


func hide_interaction() -> void:
	target_modulate = 0.0


func trigger() -> void:
	triggered.emit()
	active = false


func _set_active(value : bool) -> void:
	active = value
	set_deferred("monitorable", value)
	set_deferred("monitoring", value)


func _input_mode_changed() -> void:
	if InputMode.is_keyboard():
		if message != "":
			tooltip_label.text = "CTRL\n" + message
		else:
			tooltip_label.text = "CTRL"
	elif InputMode.is_gamepad():
		if message != "":
			tooltip_label.text = "DPAD-DOWN\n" + message
		else:
			tooltip_label.text = "DPAD-DOWN"


func _on_body_entered(body):
	player_ref = body

  
func _on_body_exited(body):
	player_ref = null
