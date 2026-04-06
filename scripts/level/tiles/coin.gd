class_name Coin
extends Area2D


func _body_entered(body: Node2D) -> void:
	if body is Player:
		body.coins += 1
		body.get_node(^"%Coin").play()
		var sparkle = preload("uid://b4pkpe44vveuw").instantiate()
		sparkle.global_position = global_position
		add_sibling(sparkle)
		queue_free()
