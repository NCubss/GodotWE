class_name Coursebot
extends Panel


func _ready() -> void:
	MusicPlayer.stream = preload("uid://dy4vtu7spkpub")
	MusicPlayer.play()
	_create_head_tween()


func _create_head_tween() -> void:
	var tween = create_tween()
	# for readability, all next time values are in frames of the original
	# head animation
	tween.set_speed_scale(18)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_loops()
	tween.tween_property(%Head, "position:y", -18, 7)
	tween.tween_property(%Head, "position:y", 0, 7) \
			.set_trans(Tween.TRANS_BOUNCE)
	tween.parallel()
	tween.tween_subtween(_shine_animation()) \
			.set_delay(4)
	tween.parallel()
	tween.tween_property(%Head, "position:y", -18, 7) \
			.set_delay(7)
	tween.tween_property(%Head, "position:y", 0, 7) \
			.set_trans(Tween.TRANS_BOUNCE)
	tween.parallel()
	tween.tween_subtween(_scale_animation(true, 2.5)) \
			.set_delay(4)
	tween.parallel()
	tween.tween_subtween(_scale_animation(false, 1)) \
			.set_delay(6.5)
	tween.tween_subtween(_scale_animation(true, 1))
	tween.tween_subtween(_scale_animation(false, 2.5))
	tween.tween_subtween(_cover_animation(true))
	tween.parallel()
	tween.tween_property(%Head, "position:y", -18, 7) \
			.set_delay(1)
	tween.tween_property(%Head, "position:y", 0, 7) \
			.set_trans(Tween.TRANS_BOUNCE)
	tween.parallel()
	tween.tween_subtween(_cover_animation(false)) \
			.set_delay(4)


func _shine_animation() -> Tween:
	var tween = create_tween()
	tween.tween_property(%LeftShine, "position", Vector2(11, 11), 3)
	tween.parallel()
	tween.tween_property(%RightShine, "position", Vector2(11, 11), 3)
	tween.tween_property(%LeftShine, "position", Vector2(-3.75, -3.75), 3) \
			.from(Vector2(-11, -11))
	tween.parallel()
	tween.tween_property(%RightShine, "position", Vector2(-3.75, -3.75), 3) \
			.from(Vector2(-11, -11))
	return tween


func _scale_animation(big: bool, time: float) -> Tween:
	var es = (14/12.0) if big else 1.0
	var ts = (8/7.0) if big else 1.0
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(%LeftEye, "scale", Vector2(es, es), time)
	tween.tween_property(%RightEye, "scale", Vector2(es, es), time)
	tween.tween_property(%LeftSpeaker, "position:x", -294 if big else -276, time)
	tween.tween_property(%RightSpeaker, "position:x", 237 if big else 219, time)
	tween.tween_property(%Title, "modulate",
			Color("98cc38") if big else Color("fbd85d"), time)
	tween.tween_property(%Title, "scale", Vector2(ts, ts), time)
	return tween


func _cover_animation(shut: bool) -> Tween:
	var tween = create_tween()
	tween.tween_property(%TopCover, "position:y", 0 if shut else -24, 3)
	tween.parallel()
	tween.tween_property(%BottomCover, "position:y", 24 if shut else 48, 3)
	return tween
