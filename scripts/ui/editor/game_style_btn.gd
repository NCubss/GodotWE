class_name GameStyleBtn
extends TextureButton

var _level: Level
var _tween: Tween
var _extend_size := 0.0
@onready var _effect = ButtonHoverEffect.new(self, Rect2(0, 0, size.x, size.y - 3))


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	%GameStylePanel.status_changed.connect(_panel_status_changed)
	await %Editor.loaded
	_level = %Editor.level


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	draw_rect(Rect2(120, 0, _extend_size, 63), Utility.COLOR_DARK)
	if _level != null:
		match _level.game_style:
			Level.GameStyle.SMB:
				draw_texture(preload("uid://ct7nsivikgx8h"), Vector2(0, 0))
			Level.GameStyle.SMB3:
				draw_texture(preload("uid://ce4hyhrbcmjlt"), Vector2(0, 0))
			Level.GameStyle.SMW:
				draw_texture(preload("uid://b548gpt5xh0v2"), Vector2(0, 0))
			Level.GameStyle.NSMBU:
				draw_texture(preload("uid://upsn5uu41qe6"), Vector2(0, 0))
	_effect.draw()


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED
		%GameStylePanel.open()
	else:
		%GameStylePanel.close()
		mouse_behavior_recursive = MOUSE_BEHAVIOR_INHERITED


func _mouse_entered() -> void:
	_effect.start()
	if not DisplayServer.is_touchscreen_available():
		UISoundPlayer.stream = preload("uid://d3lha2xpakko2")
		UISoundPlayer.play()


func _mouse_exited() -> void:
	_effect.stop()


func _panel_status_changed(_old_status: EditorPopout.Status) -> void:
	if %GameStylePanel.status == EditorPopout.Status.OPENING:
		set_pressed_no_signal(true)
		_tween = create_tween()
		_tween.set_trans(Tween.TRANS_QUAD)
		_tween.set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "_extend_size", 24, 0.1)
	elif %GameStylePanel.status == EditorPopout.Status.CLOSING:
		set_pressed_no_signal(false)
		_tween.kill()
		_extend_size = 0



func _game_style_changed(_old: Level.GameStyle) -> void:
	queue_redraw()
