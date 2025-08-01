class_name TileGen
extends Node2D

@export var source_scene: PackedScene

@export var rect: Rect2i

func _enter_tree() -> void:
	for x in range(rect.position.x, rect.position.x + rect.size.x + 1):
		for y in range(rect.position.y, rect.position.y + rect.size.y + 1):
			(owner as Map).set_tile(Vector2i(x, y), source_scene.instantiate())
	queue_free()
