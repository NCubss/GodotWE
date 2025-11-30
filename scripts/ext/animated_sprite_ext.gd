class_name AnimatedSpriteExt
extends AnimatedSprite2D

var _shadow_clone: AnimatedSprite2D

func _enter_tree() -> void:
	if not get_tree().root.is_node_ready():
		await get_tree().root.ready
	_shadow_clone = duplicate(0)
	_shadow_clone.z_index = 0
	_shadow_clone.z_as_relative = true
	Utility.id("shadows").add_child(_shadow_clone)

func _exit_tree() -> void:
	_shadow_clone.queue_free()

func _process(_delta: float) -> void:
	if _shadow_clone != null:
		_shadow_clone.animation = animation
		_shadow_clone.frame = frame
		_shadow_clone.speed_scale = speed_scale
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
