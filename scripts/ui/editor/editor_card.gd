@tool
class_name EditorCard
extends TextureButton

## The part this card represents.
@export var part: Script:
	set(v):
		if v == null:
			return
		if not is_node_ready():
			await ready
		if _editor().level == null:
			await _editor().loaded
		%Icon.texture = v.get_part_icon(_editor().level.current_sub_area)
		%Icon.texture_filter = v.get_part_icon_filter(
				_editor().level.current_sub_area)
		part = v

var _card_offset := Vector2(0, 0)
var _icon_offset := Vector2(0, 0)
var _card_offset_tween: Tween
var _icon_offset_tween: Tween


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_entered)
	mouse_exited.connect(_exited)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if _card_offset_tween != null and _card_offset_tween.is_running():
		queue_redraw()
	%Cutout.position = _card_offset + Vector2(0, 3)
	%Icon.position = _icon_offset + Vector2(3, 3)


func _draw() -> void:
	var color: Color
	if part != null:
		color = Part.get_category().color
	else:
		color = Color.GRAY
	draw_texture(preload("uid://bcyyrpipyld5c"), _card_offset, color)
	var texture: Texture2D
	if button_pressed:
		texture = preload("uid://c5s72xcashr6u")
	elif disabled:
		texture = preload("uid://cw2n8bqdit13t")
	else:
		texture = preload("uid://5mh6wpqqoc7e")
	draw_texture(texture, _card_offset + Vector2(0, 6))


func _toggled(toggled_on: bool) -> void:
	if Engine.is_editor_hint():
		return
	prints(self, toggled_on)
	if toggled_on:
		%SoundPlayer.stream = preload("uid://srqkyx5dmd3p") # selected
		if _icon_offset_tween != null:
			_icon_offset_tween.kill()
		_icon_offset_tween = create_tween()
		_icon_offset_tween.tween_interval(2)
		_icon_offset_tween.tween_property(self, "_icon_offset",
				Vector2(0, -3), 0.15) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_icon_offset_tween.tween_property(self, "_icon_offset",
				Vector2(0, 0), 0.15) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_icon_offset_tween.tween_property(self, "_icon_offset",
				Vector2(0, -3), 0.15) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_icon_offset_tween.tween_property(self, "_icon_offset",
				Vector2(0, 0), 0.15) \
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_icon_offset_tween.set_loops()
	else:
		#%SoundPlayer.stream = preload("") # deselected
		_icon_offset_tween.kill()
		_icon_offset = Vector2(0, 0)
	%SoundPlayer.play()


func _entered() -> void:
	if disabled:
		return
	if DisplayServer.is_touchscreen_available():
		return
	UISoundPlayer.stream = preload("uid://b5frd03c4vele")
	UISoundPlayer.play()
	if _card_offset_tween != null:
		_card_offset_tween.kill()
	_card_offset_tween = create_tween()
	_card_offset_tween.tween_property(self, "_card_offset",
			Vector2(0, -6), 0.1) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _exited() -> void:
	if _card_offset_tween != null:
		_card_offset_tween.kill()
	_card_offset_tween = create_tween()
	_card_offset_tween.tween_property(self, "_card_offset",
			Vector2(0, 0), 0.1) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _editor() -> Editor:
	return (get_tree().current_scene as Level).editor
