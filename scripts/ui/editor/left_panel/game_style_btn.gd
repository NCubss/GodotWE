class_name GameStyleBtn
extends PopoutBtn


func _draw() -> void:
	super()
	if %Editor.level != null:
		match %Editor.level.game_style:
			Level.GameStyle.SMB:
				draw_texture(preload("uid://ct7nsivikgx8h"), Vector2(0, 0))
			Level.GameStyle.SMB3:
				draw_texture(preload("uid://ce4hyhrbcmjlt"), Vector2(0, 0))
			Level.GameStyle.SMW:
				draw_texture(preload("uid://b548gpt5xh0v2"), Vector2(0, 0))
			Level.GameStyle.NSMBU:
				draw_texture(preload("uid://upsn5uu41qe6"), Vector2(0, 0))
	effect.draw()



func _game_style_changed(_old: Level.GameStyle) -> void:
	queue_redraw()
