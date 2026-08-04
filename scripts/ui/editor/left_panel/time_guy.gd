@tool
class_name TimeGuy
extends Control
## Displays the clock and time in the editor's time popout.

## Clock position.
const CLOCK_POS = Vector2(24, 0)
## The duration of the clock's animation.
const DURATION = 4/9.0
## Clock's standing texture.
const STAND = preload("uid://covhx3gfcp1sg")
## Hand position on the standing texture.
const STAND_HAND_POS = Vector2(22.5, 34.5)
## Clock's squatting texture.
const SQUAT = preload("uid://cfccqv11vlkcb")
## Hand position on the squatting texture.
const SQUAT_HAND_POS = Vector2(22.5, 40.5)
## Clock hand texture which gets rotated.
const HAND = preload("uid://02rillwxbyxq")
## The amount of time the hand takes to do one full loop.
const HAND_DURATION = 16/9.0
## Pivot of the hand texture.
const HAND_PIVOT = Vector2(4.5, 4.5)
## Position of the displayed time.
const TIME_POS = Vector2(0, 105)
## Width of the digit textures including spacing.
const DIGIT_WIDTH = 33
## Table of each digit texture. Keys are string digits.
const DIGITS = {
	"0": preload("uid://bafoo6lwh6w6l"),
	"1": preload("uid://bht35baa147k2"),
	"2": preload("uid://bds2notk413d3"),
	"3": preload("uid://bkmkfg7luh44f"),
	"4": preload("uid://bmtt1a7o63a2a"),
	"5": preload("uid://pwj8s1dp4tln"),
	"6": preload("uid://bojy3xln3b0ku"),
	"7": preload("uid://b1xthiylnn600"),
	"8": preload("uid://xwyrkdm5vwn4"),
	"9": preload("uid://djeah41f72dqn"),
}

var hand_rotation := 0.0


func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "hand_rotation", TAU, HAND_DURATION).from(0.0)
	tween.set_loops()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_animation_slice(DURATION, 0, DURATION / 2)
	draw_texture(STAND, CLOCK_POS)
	draw_set_transform(CLOCK_POS + STAND_HAND_POS, hand_rotation)

	draw_animation_slice(DURATION, DURATION / 2, DURATION)
	draw_texture(SQUAT, CLOCK_POS)
	draw_set_transform(CLOCK_POS + SQUAT_HAND_POS, hand_rotation)

	draw_end_animation()
	draw_texture(HAND, -HAND_PIVOT)
	draw_set_transform(Vector2(0, 0))

	var time: String
	if Engine.is_editor_hint():
		time = "000"
	elif %Editor.level != null:
		time = str(%Editor.level.time).lpad(3, "0")
	else:
		return

	for i in range(3):
		var pos = TIME_POS + Vector2(i * DIGIT_WIDTH, 0)
		draw_texture(DIGITS[time[i]], pos)
