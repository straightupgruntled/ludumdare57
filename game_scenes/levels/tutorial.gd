class_name TutorialLevel
extends Level

@onready var wall = $TutorialWalls/Wall

@onready var groundtip_1 = $TutorialText/Groundtip1
@onready var groundtip_2 = $TutorialText/Groundtip2
@onready var groundtip_3 = $TutorialText/Groundtip3
@onready var groundtip_4 = $TutorialText/Groundtip4


func _ready():
	player = $Player
	player.light_active = true
	player.can_move = true
	Global.enemies_killed = 0
	EventBus.tutorial_enemies_killed.connect(wall.trigger)
	InputMode.input_type_changed.connect(input_changed)
	input_changed()


func input_changed() -> void:
	if InputMode.is_gamepad():
		groundtip_1.text = "Left Stick to Move\nX or Stick Down to Sprint"
		groundtip_2.text = "A to Jump"
		groundtip_3.text = "RIGHT BUMPER/TRIGGER TO THROW PICK\nLEFT BUMPER/TRIGGER TO BLOCK BULLETS\nA TO JUMP ON ENEMIES"
	elif InputMode.is_keyboard():
		groundtip_1.text = "WASD or ARROWS to Move\nSHIFT to Sprint"
		groundtip_2.text = "SPACE to Jump"
		groundtip_3.text = "LEFT CLICK TO THROW PICK\nRIGHT CLICK TO BLOCK BULLETS\nSPACE TO JUMP ON ENEMIES"
