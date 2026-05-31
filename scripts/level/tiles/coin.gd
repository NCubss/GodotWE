class_name Coin
extends Area2D

@export var coin_val: int = 1

func _body_entered(body: Node2D) -> void:
	if not is_queued_for_deletion() and body is Player:
		EventBus.emit(
			EventBusConstants.N_PLAYER_ADDED_COIN,
			[body, coin_val]
		)
		body.coins += coin_val
		body.get_node(^"%Coin").play()
		var sparkle = preload("uid://b4pkpe44vveuw").instantiate()
		sparkle.global_position = global_position
		add_sibling(sparkle)
		queue_free()
