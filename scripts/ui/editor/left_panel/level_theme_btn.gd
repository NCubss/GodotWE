class_name LevelThemeBtn
extends PopoutBtn


func _draw() -> void:
	super()
	if %Editor.level != null:
		draw_texture(get_icon(), Vector2(0, 0))
	effect.draw()


func get_icon() -> Texture2D:
	# TODO
	match %Editor.level.current_sub_area.level_theme:
		Level.LevelTheme.OVERWORLD:
			return preload("uid://ctrkdmxglq366")
		Level.LevelTheme.UNDERGROUND:
			return preload("uid://ck1yw5h44os4e")
		Level.LevelTheme.UNDERWATER:
			return preload("uid://b0uvo8kpgrq7o")
		Level.LevelTheme.CASTLE:
			return preload("uid://bf1g7e5oqy43s")
		Level.LevelTheme.SKY:
			return preload("uid://c7kwwdpj5ma3g")
		Level.LevelTheme.AIRSHIP:
			return preload("uid://dwjwkq1oro4gt")
		Level.LevelTheme.DESERT:
			return preload("uid://bwx2xnyaum6wl")
		Level.LevelTheme.SNOW:
			return preload("uid://c73s37wmwcsid")
		Level.LevelTheme.MANSION:
			return preload("uid://g6k3bqnox626")
		Level.LevelTheme.FOREST:
			return preload("uid://bx5rlkh4wssxr")
		Level.LevelTheme.FALL:
			return preload("uid://dpws7gqofoyxn")
		Level.LevelTheme.BEACH:
			return preload("uid://tx80fgd83eo5")
		Level.LevelTheme.MOUNTAIN:
			if %Editor.level.current_sub_area.night_mode:
				return preload("uid://31qnqd457xrl")
			else:
				return preload("uid://kn5i6sbqd82i")
		_:
			return preload("uid://ctrkdmxglq366")
