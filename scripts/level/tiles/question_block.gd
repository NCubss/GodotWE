class_name QuestionBlock
extends StaticBodyExt


func _sprout_end(
		_eject_direction: Vector2,
		_activator: PhysicsBody2D,
		empty: bool) -> void:
	if empty:
		var sprite = Sprite2D.new()
		sprite.texture = preload("uid://qacwjfywv21u")
		%Sprite.add_sibling(sprite)
		%Sprite.queue_free()
		%BlockComponent.enabled = false
