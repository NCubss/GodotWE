class_name Grid
extends Node2D
## Draws a grid spanning the viewport.

## The size of one grid space.
@export var space_size := Vector2(16, 16)
## The color for minor grid lines.
@export var minor_color := Color(Color.WHITE, 0.6)
## The width of minor grid lines.
@export var minor_width := 1.0
## The color for major grid lines.
@export var major_color := Color.WHITE
## The width of major grid lines.
@export var major_width := 2.0
## After this many of grid spaces, the grid will draw a major grid line instead
## of a minor one.
@export var major_grid_size := Vector2i(24, 14)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var rect = Utility.get_visible_rect().grow(max(minor_width, major_width) / 2)
	for x in Utility.rangef(
			ceil(rect.position.x / space_size.x) * space_size.x,
			ceil(rect.end.x / space_size.x) * space_size.x,
			space_size.x
	):
		if fposmod(x / space_size.x, major_grid_size.x) == 0:
			draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y),
					major_color, major_width)
		else:
			draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y),
					minor_color, minor_width)
	for y in Utility.rangef(
			ceil(rect.position.y / space_size.y) * space_size.y,
			ceil(rect.end.y / space_size.y) * space_size.y,
			space_size.y
	):
		if fposmod(y / space_size.y, major_grid_size.y) == 0:
			draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y),
					major_color, major_width)
		else:
			draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y),
					minor_color, minor_width)
