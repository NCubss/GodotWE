class_name TimeBtn
extends PopoutBtn


func _ready() -> void:
	super()
	await %Editor.loaded
	%Editor.level.time_changed.connect(queue_redraw)


func get_digit(pos: int) -> Texture2D:
	var digit = str(%Editor.level.time).lpad(3, "0")[pos]
	match digit:
		"0":
			return preload("uid://bx3yk5l6m47kw")
		"1":
			return preload("uid://cs0343bvdcb78")
		"2":
			return preload("uid://dx6kc1jdp3lc")
		"3":
			return preload("uid://dsiwp68sjlpma")
		"4":
			return preload("uid://buds58a161ofu")
		"5":
			return preload("uid://cksj00x8o2ixo")
		"6":
			return preload("uid://d1ubi4lkbvnd7")
		"7":
			return preload("uid://cr1ibby6sxyck")
		"8":
			return preload("uid://cavopx8jkd5gh")
		"9":
			return preload("uid://ci2y676veauad")
		_:
			return preload("uid://bx3yk5l6m47kw")


func _draw() -> void:
	super()
	for i in range(3):
		var pos = Vector2(i * 18 + 54, 21)
		var color = Color.WHITE if button_pressed else Color.BLACK
		draw_texture(get_digit(i), pos, color)
	effect.draw()
