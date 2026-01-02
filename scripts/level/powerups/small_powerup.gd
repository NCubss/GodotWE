class_name SmallPowerup
extends Powerup


func start(_animate := false) -> void:
	var coll_shape = player.get_node("CollShape") as CollisionShape2D
	coll_shape.position = player.SMALL_HITBOX_SIZE.position
	coll_shape.shape.size = player.SMALL_HITBOX_SIZE.size
