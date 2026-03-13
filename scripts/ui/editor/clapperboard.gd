class_name Clapperboard
extends TextureButton

var body_rotation := 0.0
var top_rotation := 0.0

var _tween: Tween

@onready var _effect := ButtonHoverEffect.new(self, Rect2(0, 0, size.x, size.y))


func _ready() -> void:
	mouse_entered.connect(_effect.start)
	mouse_exited.connect(_effect.stop)


func _process(_delta: float) -> void:
	if _tween != null and _tween.is_running():
		queue_redraw()
	_effect.check_redraw()


func _pressed() -> void:
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "top_rotation", -TAU/18, 0.1) \
			.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "top_rotation", 0, 0.1) \
			.set_ease(Tween.EASE_IN)
	_tween.tween_callback(_switch)
	_tween.tween_property(self, "body_rotation", TAU/18, 0.2) \
			.set_ease(Tween.EASE_OUT)
	_tween.parallel()
	_tween.tween_property(self, "top_rotation", TAU/18, 0.2) \
			.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "body_rotation", 0, 0.2) \
			.set_ease(Tween.EASE_IN)
	_tween.parallel()
	_tween.tween_property(self, "top_rotation", 0, 0.2) \
			.set_ease(Tween.EASE_IN)


func _draw() -> void:
	if %Editor.level == null:
		return
	draw_set_transform(Vector2(4.5,  4.5), top_rotation)
	draw_texture(preload("uid://djr8pstm3pggh"), Vector2(-4.5, -4.5))
	var text: StringName
	var texture: Texture2D
	match %Editor.level.status:
		Level.Status.PLAYING:
			text = &"CLAPPERBOARD_EDIT"
			texture = preload("uid://bl2ulwdpa8lsl")
		Level.Status.EDITING:
			text = &"CLAPPERBOARD_PLAY"
			texture = preload("uid://cuspcruqbtpj4")
	draw_set_transform(Vector2(4.5, 4.5), body_rotation)
	draw_texture(texture, Vector2(-4.5, -4.5))
	draw_string(
			get_theme_default_font(),
			Vector2(4.5, 73.5),
			tr(text),
			HORIZONTAL_ALIGNMENT_CENTER,
			99,
			get_theme_default_font_size(),
			Color.WHITE,
			TextServer.JUSTIFICATION_NONE,
			TextServer.DIRECTION_AUTO,
			TextServer.ORIENTATION_HORIZONTAL,
			2)
	_effect.draw()


func _editor_loaded() -> void:
	queue_redraw()


func _switch() -> void:
	UISoundPlayer.stream = preload("uid://cdi0jrkmhuxs6")
	UISoundPlayer.play()
	if %Editor.level.status == Level.Status.PLAYING:
		%Editor.level.edit()
	elif %Editor.level.status == Level.Status.EDITING:
		%Editor.level.play()
