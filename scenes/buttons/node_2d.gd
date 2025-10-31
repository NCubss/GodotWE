extends Node2D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		Global.edit_mode = not Global.edit_mode
