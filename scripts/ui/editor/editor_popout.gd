@tool
class_name EditorPopout
extends Control
## Additional panel in the [Editor] that can be extended.
##
## An [EditorPopout] holds additional UI elements in the editor that can't
## always be displayed. Popouts are typically opened via [PopoutBtn]s and hold
## controls relevant to specific elements of a level. When open, they disable
## the rest of the editor with [member mouse_filter] and [member
## Editor.part_interact].
## [br][br]
## [b]Note:[/b] Popouts control the [member Color.a] of their childrens'
## [member modulate]. You can avoid this by using [member self_modulate] or,
## in case of modulating children, use an extra [Control]. 

## Emitted when the [member status] changes.
signal status_changed(old_status: Status)

## Directions the popout can pop out in.
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

## The popout's [StyleBox]es for each [enum PopoutDirection].
const STYLEBOXES = {
	PopoutDirection.TO_LEFT: preload("uid://bnr6dtap0gnw6"),
	PopoutDirection.TO_RIGHT: preload("uid://bvw67auia0fcv"),
}
## Close button scenes for each [enum PopoutDirection]. These must have anchors
## and offsets preconfigured.
const CLOSE_BTNS = {
	PopoutDirection.TO_LEFT: preload("uid://c4s40eed512te"),
	PopoutDirection.TO_RIGHT: preload("uid://rhafm2wkc6hk"),
}
## The duration of the popout's open and close animation.
const DURATION = 0.25
## Once the [member progress] is past this constant, content inside the popout
## starts to fade in. Higher values are better or else the content will be more
## visible during the transition, but it mustn't be larger than 1 or [member
## progress] will never reach it.
const OPACITY_DELAY = 0.75
## The [enum Tween.TransitionType] of the popout's open and close animation.
const TRANSITION = Tween.TRANS_QUAD
## The title text's distance from the top of the popout to its baseline.
const TITLE_Y = 36.0
## The title text color. Alpha does not matter as it is overwritten by the
## transition.
const TITLE_COLOR = Color.WHITE

## The side to which the popout will open in.
@export var side: PopoutDirection:
	set = _set_side
## The title of the popout as a translation key.
@export var title: StringName
## Whether the popout will have a close button.
@export var has_close_button := true
## The sound played once the popout opens.
@export var open_sound: AudioStream = preload("uid://c8fexyefwlmfs")
## The sound played once the popout closes.
@export var close_sound: AudioStream = preload("uid://dy8hcmykup336")
@export var panel_handle: EditorPanelHandle

## This popout's close button, if [member has_close_button] is
## [code]true[/code].
var close_btn: TextureButton
## The sound player used to play [member open_sound] and [member close_sound].
var sound_player: AudioStreamPlayer
## The popout's current [enum Status]. Emits [signal status_changed] when set.
var status := Status.CLOSED:
	set = _set_status
## The [StyleBox] this popout is currently using. To change the appearance,
## change the [constant STYLEBOXES] instead.
var stylebox: StyleBox
## Tween responsible for changing the popout's transition [member progress].
var tween: Tween
## Value from 0 to 1 representing how open the popout is on a linear scale (i.e.
## the [member tween] already eases this value).
var progress := 0.0
## The size this popout will be once opened. This is set when the node is ready,
## so you can simply configure the size in the editor scene.
var target_size: Vector2


func _ready() -> void:
	clip_contents = true
	offset_transform_enabled = true

	if not Engine.is_editor_hint():
		visible = false
		target_size = size
		sound_player = AudioStreamPlayer.new()
		add_child(sound_player)

	_set_side(side)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	for i in get_children():
		if i is CanvasItem:
			i.modulate.a = get_opacity()

	match side:
		PopoutDirection.TO_LEFT:
			offset_transform_position.x = lerpf(
					target_size.x, get_combined_minimum_size().x, progress)
			size.x = lerpf(
					get_combined_minimum_size().x, target_size.x, progress)
		PopoutDirection.TO_RIGHT:
			offset_transform_position_ratio.x = 0
			size.x = target_size.x * progress

	if tween != null and tween.is_running():
		queue_redraw()


func _draw() -> void:
	draw_style_box(STYLEBOXES[side], Rect2(Vector2(0, 0), size))
	draw_string(
			get_theme_default_font(),
			Vector2(0, TITLE_Y),
			tr(title),
			HORIZONTAL_ALIGNMENT_CENTER,
			size.x,
			get_theme_default_font_size(),
			Color(TITLE_COLOR, get_opacity()))


## Opens the popout. Equivalent to setting [member status] to [constant
## OPENING].
func open() -> void:
	status = Status.OPENING


## Closes the popout. Equivalent to setting [member status] to [constant
## CLOSING].
func close() -> void:
	status = Status.CLOSING


## Returns how opaque this popout's children should be based on [member
## progress]. The popout already manages its childrens' opacity, so this is
## rarely needed outside of the popout itself.
func get_opacity() -> float:
	return clampf(remap(progress, 0.75, 1, 0, 1), 0, 1)


func _set_side(v: PopoutDirection) -> void:
		side = v
		stylebox = STYLEBOXES[v]
		queue_redraw()

		if has_close_button and not Engine.is_editor_hint():
			if close_btn != null:
				close_btn.queue_free()
			close_btn = CLOSE_BTNS[v].instantiate()
			add_child(close_btn)
			close_btn.pressed.connect(close)


func _set_status(v: Status) -> void:
	if status == v or Engine.is_editor_hint():
		return
	var old = status
	status = v

	match v:
		Status.OPENING:
			sound_player.stream = open_sound
			sound_player.play()

			visible = true
			mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
			%Editor.part_interact = false
			%Editor.mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
			panel_handle.hide()

			if tween != null and tween.is_valid():
				tween.kill()
			tween = create_tween() \
					.set_trans(TRANSITION) \
					.set_ease(Tween.EASE_OUT)
			tween.tween_property(self, ^"progress", 1.0, DURATION)
			tween.tween_callback(func(): status = Status.OPEN)

		Status.OPEN:
			visible = true
			progress = 1
			mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED
			%Editor.part_interact = false
			%Editor.mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
			panel_handle.hide()

		Status.CLOSING:
			sound_player.stream = close_sound
			sound_player.play()

			visible = true
			mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
			%Editor.part_interact = false
			%Editor.mouse_behavior_recursive = MOUSE_BEHAVIOR_INHERITED
			panel_handle.hide()

			if tween != null and tween.is_valid():
				tween.kill()
			tween = create_tween() \
					.set_trans(TRANSITION) \
					.set_ease(Tween.EASE_IN)
			tween.tween_property(self, ^"progress", 0.0, DURATION)
			tween.tween_callback(func(): status = Status.CLOSED)

		Status.CLOSED:
			visible = false
			progress = 0
			mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
			%Editor.part_interact = true
			%Editor.mouse_behavior_recursive = MOUSE_BEHAVIOR_INHERITED
			panel_handle.show()

	queue_redraw()

	status_changed.emit(old)
