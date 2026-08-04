@tool
class_name TimeBtn
extends PopoutBtn

## Position of the displayed time.
const TIME_POS = Vector2(54, 21)
## Width of the digit textures including spacing.
const DIGIT_WIDTH = 18
## Table of each digit texture. Keys are string digits.
const DIGITS = {
	"0": preload("uid://bx3yk5l6m47kw"),
	"1": preload("uid://cs0343bvdcb78"),
	"2": preload("uid://dx6kc1jdp3lc"),
	"3": preload("uid://dsiwp68sjlpma"),
	"4": preload("uid://buds58a161ofu"),
	"5": preload("uid://cksj00x8o2ixo"),
	"6": preload("uid://d1ubi4lkbvnd7"),
	"7": preload("uid://cr1ibby6sxyck"),
	"8": preload("uid://cavopx8jkd5gh"),
	"9": preload("uid://ci2y676veauad"),
}


func _ready() -> void:
	super()
	if not Engine.is_editor_hint():
		await %Editor.loaded
		queue_redraw()
		%Editor.level.time_changed.connect(queue_redraw)


func _draw() -> void:
	super()

	var time: String
	if Engine.is_editor_hint():
		time = "000"
	elif %Editor.level != null:
		time = str(%Editor.level.time).lpad(3, "0")
	else:
		return

	for i in range(3):
		var pos = TIME_POS + Vector2(i * DIGIT_WIDTH, 0)
		var color = Color.WHITE if button_pressed else Color.BLACK
		draw_texture(DIGITS[time[i]], pos, color)

	effect.draw()
