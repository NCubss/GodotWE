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
