class_name CoursebotBtn
extends TextureButton

var _extend_size := 0.0
var _tween: Tween

@onready var _effect := ButtonHoverEffect.new(self, Rect2(0, 0, size.x, size.y - 6))


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	_effect.check_redraw()
	if _tween != null and _tween.is_running():
		queue_redraw()


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		_tween = create_tween()
		_tween.tween_property(self, "_extend_size", 30, 0.1) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		%CoursebotPanel.open()
	else:
		_tween.kill()
		_extend_size = 0
		%CoursebotPanel.close()
		queue_redraw()


func _draw() -> void:
	# reset transformations
	get_canvas_transform()
	draw_set_transform_matrix(Transform2D.IDENTITY)
	# draw button extension to the popout
	draw_rect(Rect2(12 - _extend_size, 0, _extend_size, 60), Color("#590f10"))
	# draw icon
	if button_pressed:
		draw_texture(preload("uid://buxq70s1a6ypq"), Vector2(0, 0))
	else:
		draw_texture(preload("uid://ciqrifuodxf7m"), Vector2(0, 0))
	_effect.draw()


func _mouse_entered() -> void:
	_effect.start()
	if GameSettings.show_hover_effect:
		UISoundPlayer.stream = preload("uid://bbc6fa1b5njqq")
		UISoundPlayer.play()


func _mouse_exited() -> void:
	_effect.stop()
