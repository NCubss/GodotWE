@tool
extends TextureRect

const COLOR = Color(1, 1, 1, 0.5)

var draw_grid := false:
	set = _set_draw_grid


func _draw() -> void:
	if draw_grid:
		draw_set_transform((size - Vector2(180, 180)) / 2)
		draw_line(Vector2(42, 0), Vector2(42, 180), COLOR)
		draw_line(Vector2(138, 0), Vector2(138, 180), COLOR)
		draw_line(Vector2(0, 42), Vector2(180, 42), COLOR)
		draw_line(Vector2(0, 138), Vector2(180, 138), COLOR)
		draw_rect(Rect2(9, 9, 162, 162), COLOR, false)


func _set_draw_grid(v: bool) -> void:
	if draw_grid != v:
		draw_grid = v
		queue_redraw()
