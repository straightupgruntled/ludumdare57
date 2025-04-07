extends Control

@onready var heart_1 = $Heart1
@onready var heart_2 = $Heart2
@onready var heart_3 = $Heart3


func _ready():
	update_health(6)


func update_health(current_health : int) -> void:
	var first_amount : int = clamp(current_health, 0, 2)
	var second_amount : int = clamp(current_health - 2, 0, 2)
	var thrid_amount : int = clamp(current_health - 4, 0, 2)
	heart_1.region_rect = Rect2(86.0 * first_amount, 0.0, 86.0, 83.0)
	heart_2.region_rect = Rect2(86.0 * second_amount, 0.0, 86.0, 83.0)
	heart_3.region_rect = Rect2(86.0 * thrid_amount, 0.0, 86.0, 83.0)
