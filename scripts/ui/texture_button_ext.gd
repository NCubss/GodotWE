class_name TextureButtonExt
extends TextureButton

@export var hover_offset: Rect2
@export var hover_sound := load("uid://bbc6fa1b5njqq")

var _hover := 3.0
var _hover_active := false
var _hover_sprite := load("uid://bxk3nfis807iy")
var _hover_tween: Tween

func _init() -> void:
	mouse_entered.connect(_hover_mouse_start)
	mouse_exited.connect(_hover_mouse_end)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if _hover_active:
		draw_set_transform(hover_offset.position)
		draw_texture(_hover_sprite,
				Vector2(-_hover, -_hover))
		draw_set_transform(Vector2(size.x, 0) + Vector2(hover_offset.end.x, hover_offset.position.y), 0, Vector2(-1, 1))
		draw_texture(_hover_sprite,
				Vector2(-_hover, -_hover))
		draw_set_transform(size + hover_offset.end, 0, Vector2(-1, -1))
		draw_texture(_hover_sprite,
				Vector2(-_hover, -_hover))
		draw_set_transform(Vector2(0, size.y) + Vector2(hover_offset.position.x, hover_offset.end.y), 0, Vector2(1, -1))
		draw_texture(_hover_sprite,
				Vector2(-_hover, -_hover))


func _hover_mouse_start() -> void:
	_hover_active = true
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "_hover", 15, 0.417) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_hover_tween.tween_property(self, "_hover", 3, 0.417) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_hover_tween.set_loops()
	UISoundPlayer.stream = hover_sound
	UISoundPlayer.play()


func _hover_mouse_end() -> void:
	_hover_active = false
	if _hover_tween != null:
		_hover_tween.kill()
	_hover = 3
