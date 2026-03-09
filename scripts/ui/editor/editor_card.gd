@tool
class_name EditorCard
extends TextureButton

const _CARD_TOP = preload("uid://bcyyrpipyld5c")
const _CARD = preload("uid://5mh6wpqqoc7e")
const _CARD_PRESSED = preload("uid://c5s72xcashr6u")

## The part this card represents.
@export var part: PartInfo

var _card_offset := Vector2(0, 0)
var _icon_offset := Vector2(0, 0)
var _card_offset_tween: Tween
var _icon_offset_tween: Tween


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_entered)
	mouse_exited.connect(_exited)
	%Icon.texture = part.icon
	%Icon.texture_filter = part.icon_filter


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if _card_offset_tween != null and _card_offset_tween.is_running():
		queue_redraw()
	%IconContainer.position = _card_offset + Vector2(6, 9)
	%Icon.position = _icon_offset


func _draw() -> void:
	var color: Color
	if part != null:
		color = PartInfo.get_category_color(part.category)
	else:
		color = Color.GRAY
	draw_texture(_CARD_TOP, _card_offset, color)
	draw_texture(_CARD_PRESSED if button_pressed else _CARD,
			_card_offset + Vector2(0, 6))


func _toggled(toggled_on: bool) -> void:
	if Engine.is_editor_hint():
		return
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
