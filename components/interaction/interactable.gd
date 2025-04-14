class_name Interactable
extends Area2D

signal entered
signal exited

@export var message : String
@export var active : bool = true : set = _set_active
@export var descent_interactor : bool = false

signal interaction_triggered(interactor : Interactor)

var target_modulate : float = 0.0

@onready var tooltip_label = $TooltipLabel


func _ready():
	InputMode.input_type_changed.connect(_input_mode_changed)
	_input_mode_changed()
	tooltip_label.modulate.a = 0.0


func _process(delta):
	global_rotation = 0.0
	tooltip_label.modulate.a = lerpf(tooltip_label.modulate.a, target_modulate, Global.lerp_factor(18.0, delta))


func show_interaction() -> void:
	target_modulate = 1.0
	entered.emit()


func hide_interaction() -> void:
	target_modulate = 0.0
	exited.emit()


func trigger(interactor : Interactor) -> void:
	interaction_triggered.emit(interactor)


func _set_active(value : bool) -> void:
	active = value
	set_deferred("monitorable", value)
	set_deferred("monitoring", value)


func _input_mode_changed() -> void:
	if !descent_interactor:
		if InputMode.is_keyboard():
			if message != "":
				tooltip_label.text = "E\n" + message
			else:
				tooltip_label.text = "E"
		elif InputMode.is_gamepad():
			if message != "":
				tooltip_label.text = "X\n" + message
			else:
				tooltip_label.text = "X"
	else:
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
