class_name Shadows
extends Node2D

@export var offset := Vector2(3, 3)


func _process(_delta: float) -> void:
	queue_redraw()
