class_name HUD
extends CanvasLayer

@export var time_label: Label
@export var score_label: Label
@export var lives_label: Label
@export var coins_label: Label

## The level associated with this HUD.
var level: Level


func _process(_delta: float) -> void:
	time_label.text = "%03d" % level.get_current_time()
