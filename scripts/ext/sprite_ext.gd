class_name SpriteExt
extends Sprite2D

var _shadow_clone: Sprite2D

func _enter_tree() -> void:
	if not get_tree().root.is_node_ready():
		await get_tree().root.ready
	_shadow_clone = duplicate(0)
	get_tree().get_first_node_in_group("shadows").add_child(_shadow_clone)

func _exit_tree() -> void:
	_shadow_clone.queue_free()

func _process(delta: float) -> void:
	if _shadow_clone != null:
		_shadow_clone.centered = centered
		_shadow_clone.offset = offset
		_shadow_clone.flip_h = flip_h
		_shadow_clone.flip_v = flip_v
		_shadow_clone.position = global_position + Vector2(3, 3)
		_shadow_clone.rotation = global_rotation
		_shadow_clone.scale = global_scale
		_shadow_clone.skew = global_skew
		_shadow_clone.visible = visible
		_shadow_clone.modulate = modulate
