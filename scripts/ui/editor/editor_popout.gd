class_name EditorPopout
extends NinePatchRect

var side: Vector2
var target_rect: Rect2
var title: String = "Save | Load"
var close: TextureButtonExt
var _tween: Tween
var _opacity := 0.0

func _init(_side: Vector2, _rect: Rect2):
	texture = preload("res://sprites/ui/editor/popout.svg")
	patch_margin_top = 54
	patch_margin_bottom = 15
	side = _side
	close = TextureButtonExt.new()
	add_child(close)
	close.texture_normal = preload("res://sprites/ui/btn_close.svg")
	close.anchor_left = 1
	close.anchor_right = 1
	close.offset_top = 8
	close.offset_bottom = close.size.y + 8
	match side:
		Vector2.LEFT:
			region_rect = Rect2(27, 0, 27, 72)
			patch_margin_left = 9
			patch_margin_right = 15
			close.offset_left = -close.size.x - 15
			close.offset_right = -15
		Vector2.RIGHT:
			region_rect = Rect2(0, 0, 27, 72)
			patch_margin_left = 15
			patch_margin_right = 9
			close.offset_left = -close.size.x - 9
			close.offset_right = -9
	Utility.id("editor").add_child(self)
	target_rect = _rect
	# Animating in
	position = Vector2(_rect.end.x - get_minimum_size().x, _rect.position.y)
	size = Vector2(get_minimum_size().x, _rect.size.y)
	_tween = create_tween() \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "size", _rect.size, 0.25)
	_tween.parallel().tween_property(self, "position", _rect.position, 0.25)
	_tween.parallel().tween_property(self, "_opacity", 1, 0.125) \
			.set_delay(0.125)

func _process(_delta: float) -> void:
	if close != null:
		close.modulate = Color(1, 1, 1, _opacity)
	for i: Control in get_children():
		i.modulate.a = _opacity
	queue_redraw()


func _draw() -> void:
	draw_string(
			get_theme_default_font(),
			Vector2(0, 36),
			title,
			HORIZONTAL_ALIGNMENT_CENTER,
			size.x,
			get_theme_default_font_size(),
			Color(1, 1, 1, _opacity))
