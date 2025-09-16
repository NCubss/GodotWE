class_name CoursebotBtn
extends TextureButtonExt

var panel: EditorPopout = null
var _extend_size := 0.0
var _tween: Tween


func _pressed() -> void:
	if button_pressed:
		UISoundPlayer.stream = preload("res://audio/ui/editor/panel_coursebot_open.ogg")
		_tween = create_tween()
		_tween.tween_property(self, "_extend_size", 30, 0.1) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		panel = EditorPopout.new(Vector2.RIGHT, Rect2(612, 108, 444, 495))
	else:
		UISoundPlayer.stream = preload("res://audio/ui/editor/panel_coursebot_close.ogg")
		_tween.kill()
		_extend_size = 0
		panel.queue_free()
	UISoundPlayer.play()


func _draw() -> void:
	# reset transformations
	draw_set_transform_matrix(Transform2D.IDENTITY)
	# draw button extension to the popout
	draw_rect(Rect2(12 - _extend_size, 0, _extend_size, 60), Color("#590f10"))
	# draw icon
	if button_pressed:
		draw_texture(
				preload("res://sprites/ui/editor/btn_coursebot_icon_open.svg"),
				Vector2(0, 0))
	else:
		draw_texture(
				preload("res://sprites/ui/editor/btn_coursebot_icon.svg"),
				Vector2(0, 0))
	# hover effect
	super()
