class_name EditorPopout
extends NinePatchRect

## Emitted when the popout has just begun opening.
signal opening
## Emitted when the popout has just finished opening.
signal opened
## Emitted when the popout has just begun closing.
signal closing
## Emitted when the popout has just finished closing.
signal closed

enum PopoutDirection {
	TO_LEFT,
	TO_RIGHT,
}

## The side to which the popout will open in.
@export var side: PopoutDirection:
	set(value):
		side = value
		match value:
			PopoutDirection.TO_LEFT:
				region_rect = Rect2(0, 0, 27, 72)
				patch_margin_left = 15
				patch_margin_right = 9
				close_btn.offset_right = -9
				close_btn.offset_left = -9 - close_btn.size.x
			PopoutDirection.TO_RIGHT:
				region_rect = Rect2(27, 0, 27, 72)
				patch_margin_left = 15
				patch_margin_right = 9
				close_btn.offset_right = -15
				close_btn.offset_left = -15 - close_btn.size.x
		queue_redraw()
## The title of the popout that will appear in the dark top bar.
@export var title: String
## Whether the popout will have a close button.
@export var has_close_button := true

var close_btn: TextureButtonExt

var _tween: Tween
var _opacity := 0.0


func _init():
	texture = preload("uid://cy4xwj1nrr0pc")
	patch_margin_top = 57
	patch_margin_bottom = 15
	visible = false
	close_btn = TextureButtonExt.new()
	add_child(close_btn, false, Node.INTERNAL_MODE_FRONT)
	close_btn.texture_normal = preload("uid://b0tiwkw7ublhx")
	close_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	close_btn.offset_top = 9
	close_btn.offset_bottom = close_btn.size.y + 9


## Opens the popout.
func open() -> void:
	if _tween != null:
		_tween.kill()
	# ah yes (call setter)
	side = side
	var target_rect = Rect2(position, size)
	_tween = create_tween().set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_OUT).set_parallel()
	visible = true
	size.y = target_rect.size.y
	_tween.tween_property(self, "size:x", target_rect.size.x, 0.25) \
			.from(get_combined_minimum_size().x)
	_tween.tween_property(self, "_opacity", 1, 0.125).set_delay(0.125).from(0)
	match side:
		PopoutDirection.TO_LEFT:
			position.y = target_rect.position.y
			_tween.tween_property(self, "position:x", target_rect.position.x,
					0.25) \
					.from(target_rect.end.x - get_combined_minimum_size().x)
		PopoutDirection.TO_RIGHT:
			position = target_rect.position
	opening.emit()
	_tween.finished.connect(opened.emit)


func close() -> void:
	if _tween != null:
		_tween.kill()
	var target_rect = Rect2(position, size)
	_tween = create_tween().set_trans(Tween.TRANS_QUAD) \
			.set_ease(Tween.EASE_IN).set_parallel()
	_tween.tween_property(self, "size:x", get_combined_minimum_size().x, 0.25) \
			.from(target_rect.size.x)
	_tween.tween_property(self, "_opacity", 0, 0.125).from(1)
	match side:
		PopoutDirection.TO_LEFT:
			position.y = target_rect.position.y
			_tween.tween_property(self, "position:x",
					target_rect.end.x - get_combined_minimum_size().x, 0.25) \
					.from(target_rect.position.x)
		PopoutDirection.TO_RIGHT:
			position = target_rect.position
	_tween.chain().tween_property(self, "visible", false, 0)
	_tween.tween_property(self, "size", target_rect.size, 0)
	_tween.tween_property(self, "position", target_rect.position, 0)
	closing.emit()
	_tween.finished.connect(closed.emit)



func _process(_delta: float) -> void:
	if close_btn != null:
		close_btn.modulate = Color(1, 1, 1, _opacity)
	for i: Control in get_children(true):
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
