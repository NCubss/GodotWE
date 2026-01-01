extends Node2D


func _ready() -> void:
	$Window.close_requested.connect(get_tree().quit)
