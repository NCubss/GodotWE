class_name Mushroom
extends CharacterBodyExt


func _physics_process(_delta: float) -> void:
	move_and_slide()


func _body_entered(body: Node2D) -> void:
	print(body.name)
	body = body as Player
	if body == null:
		return
	body.set_powerup(SuperPowerup.new(body), true)
	queue_free()
