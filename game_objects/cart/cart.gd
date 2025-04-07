class_name Cart
extends CharacterBody2D

@export var diamonds_collected : int = 0
@export var frozen : bool = false : set = _set_frozen

@onready var fixed_pivot = $Visuals/FixedPivot
@onready var diamond_count_label = $Visuals/FixedPivot/DiamondCountLabel
@onready var height_controller = $HeightController
@onready var hurtbox = $Hurtbox

var locked_to_platform : bool = false

func _ready():
	diamond_count_label.text = str(diamonds_collected)


func _physics_process(delta):
	fixed_pivot.global_rotation = 0.0
	if frozen:
		return
	if !locked_to_platform:
		velocity = velocity.lerp(Vector2.ZERO, .05)
		rotation = lerp_angle(rotation, velocity.angle(), .05)
	else:
		velocity = velocity.lerp(Vector2.ZERO, .2)
		rotation = lerp_angle(rotation, velocity.angle(), .2)
	move_and_slide()


func take_damage(amount : int) -> void:
	diamonds_collected -= amount * 2
	if diamonds_collected < 0:
		diamonds_collected = 0
	diamond_count_label.text = str(diamonds_collected)


func lock_to_platform() -> void:
	locked_to_platform = true
	height_controller.can_fall = false


func unlock_from_platform() -> void:
	locked_to_platform = false
	height_controller.can_fall = true


func _on_collectable_detector_body_entered(body):
	body.queue_free()
	diamonds_collected += 1
	diamond_count_label.text = str(diamonds_collected)


func _on_fell_into_pit():
	diamonds_collected /= 2
	diamond_count_label.text = str(diamonds_collected)


func _set_frozen(value : bool) -> void:
	frozen = value
	hurtbox.active = !frozen
