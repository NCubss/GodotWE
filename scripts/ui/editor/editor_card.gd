class_name EditorCard
extends TextureButton

## The button group all [EditorCard]s are in.
static var card_group := ButtonGroup.new()

## The part this card represents.
@export var part: PartInfo

var _card_offset := Vector2(0, 0)
var _icon_offset := Vector2(0, 0)
var _card_top = load("uid://bcyyrpipyld5c")
var _card = load("uid://5mh6wpqqoc7e")
var _card_pressed = load("uid://c5s72xcashr6u")
var _card_offset_tween: Tween
var _icon_offset_tween: Tween
var _sound_player := AudioStreamPlayer.new()
var _icon := Sprite2D.new()


static func _static_init() -> void:
	card_group.allow_unpress = true


func _init() -> void:
	ignore_texture_size = true
	toggle_mode = true
	button_group = card_group
	add_child(_sound_player, false, Node.INTERNAL_MODE_BACK)
	add_child(_icon, false, Node.INTERNAL_MODE_FRONT)
	_icon.centered = false
	mouse_entered.connect(_entered)
	mouse_exited.connect(_exited)


func _ready() -> void:
	_icon.texture = part.icon
	_icon.texture_filter = part.icon_filter


func _get_minimum_size() -> Vector2:
	return Vector2(66, 75)


func _process(_delta: float) -> void:
	if _card_offset_tween != null and _card_offset_tween.is_running():
		queue_redraw()
	_icon.position = _card_offset + _icon_offset + Vector2(3, 6)


func _draw() -> void:
	draw_texture(_card_top, _card_offset,
			PartInfo.get_category_color(part.category))
	draw_texture(_card_pressed if button_pressed else _card,
			_card_offset + Vector2(0, 6))


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		_sound_player.stream = load("uid://srqkyx5dmd3p") # selected
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
		_sound_player.stream = load("") # deselected
		_icon_offset_tween.kill()
		_icon_offset = Vector2(0, 0)
		
	_sound_player.play()

func _entered() -> void:
	UISoundPlayer.stream = load("uid://b5frd03c4vele")
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
