class_name Background
extends Node2D
## Custom parallax implementation that works for any viewport size.

## The texture to loop.
@export var texture: Texture2D
## Follow scale, e.g. if this is [code]Vector2(0.5, 0.5)[/code], then it will
## move half as fast as the camera.
@export var follow_scale := Vector2(1, 1)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if texture == null:
		return

	var mult = Vector2(1, 1) - follow_scale
	draw_set_transform(mult * Utility.camera_position)
	var rect = Utility.get_visible_rect()
	rect.position *= follow_scale

	var size = texture.get_size()
	var pos = (rect.position / size).floor() * size
	var end = (rect.end / size).ceil() * size
	draw_texture_rect(texture, Rect2(pos, end - pos), true)
