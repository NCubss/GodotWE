class_name HUD
extends CanvasLayer

@export var time_label: Label
@export var score_label: Label
@export var lives_label: Label
@export var coins_label: Label

## The level associated with this HUD.
var level: Level
## The player currently being kept track of.
var player: Player


func _process(_delta: float) -> void:
	time_label.text = "%03d" % level.get_current_time()
	if player != null:
		coins_label.text = "%02d" % player.coins
