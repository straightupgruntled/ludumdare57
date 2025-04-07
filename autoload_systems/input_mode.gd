### SCRIPT by Oscar North (Mr_Afroduck) ###
extends Node

const CHANGE_COOLDOWN = 0.2

signal input_type_changed

enum InputType{
	KEYBOARD,
	GAMEPAD
}

var cooldown_timer : float = 0
var current_type : InputType = InputType.KEYBOARD


func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS


func _input(event : InputEvent):
	if cooldown_timer > 0:
		return
	if event is InputEventJoypadButton:
		set_input_type(InputType.GAMEPAD)
	elif event is InputEventJoypadMotion and abs(event.axis_value) > 0.2:
		set_input_type(InputType.GAMEPAD)
	elif event is InputEventKey or event is InputEventMouseButton:
		set_input_type(InputType.KEYBOARD)
	elif event is InputEventMouseMotion:
		if event.velocity.length_squared() > 4000:
			set_input_type(InputType.KEYBOARD)


func _process(delta : float):
	cooldown_timer = move_toward(cooldown_timer, 0, delta)


func is_keyboard() -> bool:
	return current_type == InputType.KEYBOARD


func is_gamepad() -> bool:
	return current_type == InputType.GAMEPAD


func set_input_type(new_type : InputType) -> void:
	if new_type == current_type or cooldown_timer > 0:
		return

	current_type = new_type
	cooldown_timer = CHANGE_COOLDOWN
	input_type_changed.emit()

	if new_type == InputType.GAMEPAD:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
