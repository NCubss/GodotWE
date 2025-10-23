@tool
extends Container


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		for c: Control in get_children():
			c.size = Vector2(1152, 648)
			c.scale.x = size.y / c.size.y
			c.scale.y = c.scale.x
			c.position.x = (size.x - (c.size.x * c.scale.x)) / 2
			c.position.y = 0
	elif what == NOTIFICATION_CHILD_ORDER_CHANGED:
		queue_sort()
