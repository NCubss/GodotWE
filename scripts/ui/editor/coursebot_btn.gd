class_name CoursebotBtn
extends TextureButton

var panel: EditorPopout = null
var _extend_size := 0.0
var _tween: Tween
var _effect := ButtonHoverEffect.new(self, Rect2(0, 0, size.x, size.y - 6))


func _ready() -> void:
	mouse_entered.connect(_effect.start)
	if GameSettings.show_hover_effect:
		mouse_entered.connect(UISoundPlayer.start.bind("uid://bbc6fa1b5njqq"))
	mouse_exited.connect(_effect.stop)


func _process(_delta: float) -> void:
	_effect.check_redraw()
	if _tween != null and _tween.is_running():
		queue_redraw()


func _pressed() -> void:
	if button_pressed:
		UISoundPlayer.stream = load("uid://dun72febcjtln")
		_tween = create_tween()
		_tween.tween_property(self, "_extend_size", 30, 0.1) \
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		panel = EditorPopout.new(Vector2.RIGHT,
				Rect2(global_position - Vector2(462, 108), Vector2(444, 495)))
		panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	else:
		UISoundPlayer.stream = load("uid://dvblsjft053ru")
		_tween.kill()
		_extend_size = 0
		panel.queue_free()
		queue_redraw()
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
	_effect.draw()
