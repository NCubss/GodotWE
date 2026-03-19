class_name TitleClapperboard
extends TextureButton

enum Type {
	EDIT,
	PLAY,
}

@export var type: Type

var _top_rotation := 0.0
var _body_rotation := 0.0

@onready var _effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	mouse_entered.connect(_effect.start)
	mouse_exited.connect(_effect.stop)


func _process(_delta: float) -> void:
	_effect.check_redraw()


func _pressed() -> void:
	disabled = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "_top_rotation", TAU / -32, 0.1) \
			.set_ease(Tween.EASE_OUT)
	tween.parallel()
	tween.tween_property(self, "_body_rotation", TAU / 32, 0.1) \
			.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_top_rotation", 0, 0.1) \
			.set_ease(Tween.EASE_IN)
	tween.parallel()
	tween.tween_property(self, "_body_rotation", 0, 0.1) \
			.set_ease(Tween.EASE_IN)
	tween.tween_callback(_switch)


func _draw() -> void:
	draw_set_transform(Vector2(7.5, 7.5), _top_rotation)
	draw_texture(preload("uid://lk5l7pauak3e"), Vector2(-7.5, -7.5))
	draw_set_transform(Vector2(7.5, 7.5), _body_rotation)
	draw_texture(preload("uid://bcljwjrx5mjds"), Vector2(-7.5, -7.5))
	var text: StringName
	match type:
		Type.EDIT:
			text = &"TITLE_CLAPPERBOARD_EDIT"
		Type.PLAY:
			text = &"TITLE_CLAPPERBOARD_PLAY"
	draw_string(
			get_theme_default_font(),
			Vector2(-4.5, 72),
			tr(text),
			HORIZONTAL_ALIGNMENT_CENTER,
			138,
			get_theme_default_font_size(),
			Color.WHITE,
			TextServer.JUSTIFICATION_NONE,
			TextServer.DIRECTION_AUTO,
			TextServer.ORIENTATION_HORIZONTAL,
			2)
	_effect.draw()


func _switch() -> void:
	%Sounds.play()
	%Clapperboards.hide()
	match type:
		Type.EDIT:
			MusicPlayer.stream = preload("uid://djreippxa0ugn")
			MusicPlayer.play()
			_animate_logo()
		Type.PLAY:
			%Pages.show()


func _animate_logo() -> void:
	var tween = create_tween()
	for i in %Logo.get_children():
		tween.tween_property(i, "position:y", 648, 1/12.0)
	tween.tween_interval(0.5)
	var level: Level = get_tree().current_scene
	tween.tween_callback(func():
		level.create_editor()
		level.edit()
		level.title_screen = false
		# fake a scene change
		level.scene_file_path = ResourceUID.uid_to_path("uid://cbc3kaegk4jn3")
		get_tree().scene_changed.emit()
	)
	var info_tween = create_tween()
	info_tween.set_trans(Tween.TRANS_QUAD)
	info_tween.set_ease(Tween.EASE_IN)
	info_tween.tween_property(%Info, "position:y", 694, 0.2)
