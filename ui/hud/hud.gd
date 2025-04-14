class_name HUD
extends CanvasLayer

@export var player : Player

@onready var player_health_bar = $PlayerHealthBar
@onready var pick_ui = $PickUI
@onready var death_screen = $DeathScreen
@onready var diamonds_collected = $DiamondCounter/DiamondsCollected
@onready var gears_collected = $GearCounter/GearsCollected
@onready var hyper_boost_panel = $HyperBoostPanel


func _ready():
	if player:
		player.health_updated.connect(player_health_bar.update_health)
		player.pick_count_updated.connect(pick_ui.update_pick_count)
		player.died.connect(death_screen.trigger_game_over)
		hyper_boost_panel.player = player


func _process(delta):
	diamonds_collected.text = str(Global.diamonds)
	gears_collected.text = str(Global.gears)
