class_name AutoscrollBtn
extends PopoutBtn


func _draw() -> void:
	super()
	if %Editor.level != null:
		draw_texture(get_icon(), Vector2(0, 0))
	effect.draw()


func get_icon() -> Texture2D:
	# TODO
	match %Editor.level.current_sub_area.autoscroll:
		Level.Autoscroll.NONE:
			return preload("uid://c6tfsjisma3ft")
		_:
			return preload("uid://c6tfsjisma3ft")
