class_name Galoomba
extends Enemy


func _stomped(player: Player) -> void:
	super(player)
	if is_queued_for_deletion():
		return
	var stomp: StompedGaloomba = preload("uid://x314ug2d52hj").instantiate()
	stomp.global_position = global_position
	stomp.level = level
	stomp.sub_area = sub_area
	add_sibling.call_deferred(stomp)
	queue_free()
