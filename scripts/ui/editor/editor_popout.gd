class_name EditorPopout
extends NinePatchRect

## Emitted when the [member status] changes.
signal status_changed(old_status: Status)

## A direction the popout can pop out in.
enum PopoutDirection {
	TO_LEFT,
	TO_RIGHT,
}
## Represents the popout's current status.
enum Status {
	CLOSED,
	OPENING,
	OPEN,
	CLOSING,
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
				if has_close_button:
					close_btn.offset_right = -9
					close_btn.offset_left = -9 - close_btn.size.x
			PopoutDirection.TO_RIGHT:
				region_rect = Rect2(27, 0, 27, 72)
				patch_margin_left = 9
				patch_margin_right = 15
				if has_close_button:
					close_btn.offset_right = -15
					close_btn.offset_left = -15 - close_btn.size.x
		queue_redraw()
## The title of the popout that will appear in the dark top bar.
@export var title: String
## Whether the popout will have a close button.
@export var has_close_button := true
## The sound played once the popout opens.
@export var open_sound: AudioStream = preload("uid://c8fexyefwlmfs")
## The sound played once the popout closes.
@export var close_sound: AudioStream = preload("uid://dy8hcmykup336")

## This popout's close button, if [member has_close_button] is [code]true[/code].
var close_btn := TextureButton.new()
## The sound player used to play [member open_sound] and [member close_sound].
var sound_player := AudioStreamPlayer.new()
## The popout's current [enum Status]. Emits [signal status_changed] when set.
var status := Status.CLOSED:
	set(v):
		if status == v:
			return
		var old = status
		status = v
		status_changed.emit(old)

var _tween: Tween
var _opacity := 0.0

## The target [Rect2] this popout will scale to once open.
@onready var target_rect := get_rect()


func _ready() -> void:
	texture = preload("uid://cy4xwj1nrr0pc")
	patch_margin_top = 57
	patch_margin_bottom = 15
	visible = false
	add_child(sound_player)
	if has_close_button:
		add_child(close_btn)
		close_btn.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		close_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT, true)
		close_btn.texture_normal = preload("uid://b0tiwkw7ublhx")
		close_btn.offset_top = 9
		close_btn.offset_bottom = close_btn.size.y + 9
		close_btn.pressed.connect(close)
	side = side


## Opens the popout.
func open() -> void:
	sound_player.stream = open_sound
	sound_player.play()
	if _tween != null:
		_tween.kill()
	status = Status.OPENING
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
	_tween.finished.connect(func(): status = Status.OPEN)


func close() -> void:
	sound_player.stream = close_sound
	sound_player.play()
	status = Status.CLOSING
	if _tween != null:
		_tween.kill()
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
	_tween.finished.connect(func(): status = Status.CLOSED)



func _process(_delta: float) -> void:
	for i in get_children():
		if i is not CanvasItem:
			continue
		i.modulate.a = _opacity
	if _tween != null and _tween.is_running():
		queue_redraw()


func _draw() -> void:
	draw_string(
			get_theme_default_font(),
			Vector2(0, 36),
			tr(title),
			HORIZONTAL_ALIGNMENT_CENTER,
			size.x,
			get_theme_default_font_size(),
			Color(1, 1, 1, _opacity))
