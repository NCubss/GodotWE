class_name RiseSprout
extends Sprout


func end_sprout(direction: Vector2) -> SproutReturnData:
	visible = true
	%Sound.play()
	var tween = %Sprite.create_tween()
	# shadow fix
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(%Sprite, "position", direction * 16, 0.5)
	tween.finished.connect(_die)
	var data = SproutReturnData.new()
	data.new_tile = preload("res://scenes/tiles/empty_block.tscn")
	return data


func _die() -> void:
	if %Sound.playing:
		await %Sound.finished
	#queue_free()
