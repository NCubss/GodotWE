class_name CoursebotBtn
extends PopoutBtn


func _draw() -> void:
	super()
	if button_pressed:
		draw_texture(preload("uid://buxq70s1a6ypq"), Vector2(0, 0))
	else:
		draw_texture(preload("uid://ciqrifuodxf7m"), Vector2(0, 0))
	effect.draw()
