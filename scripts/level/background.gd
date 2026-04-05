class_name Background
extends Node2D

@export var texture: Texture2D
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
	var start = (rect.position / texture.get_size()).floor() * texture.get_size()
	var end = (rect.end / texture.get_size()).ceil() * texture.get_size()
	draw_texture_rect(texture, Rect2(start, end - start), true)
