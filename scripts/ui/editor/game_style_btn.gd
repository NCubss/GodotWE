class_name GameStyleBtn
extends TextureButton

var _tween: Tween
var _extend_size := 0.0

@onready var _level: Level = Utility.id("level")
@onready var _effect = ButtonHoverEffect.new(self, Rect2(0, 0, size.x, size.y - 3))


func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	_level.game_style_changed.connect(_game_style_changed)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _draw() -> void:
	draw_rect(Rect2(120, 0, _extend_size, 63), Utility.COLOR_DARK)
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
		%GameStylePanel.open()
		_tween = create_tween()
		_tween.set_trans(Tween.TRANS_QUAD)
		_tween.set_ease(Tween.EASE_OUT)
		_tween.tween_property(self, "_extend_size", 24, 0.1)
	else:
		%GameStylePanel.close()
		_tween.kill()
		_extend_size = 0


func _mouse_entered() -> void:
	_effect.start()
	if GameSettings.show_hover_effect:
		UISoundPlayer.stream = preload("uid://d3lha2xpakko2")
		UISoundPlayer.play()


func _mouse_exited() -> void:
	_effect.stop()


func _game_style_changed(_old: Level.GameStyle) -> void:
	queue_redraw()
