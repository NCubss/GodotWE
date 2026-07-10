class_name SpinSmoke
extends AnimatedSprite2D

const _LENGTH = 4/15.0
const _STAR = preload("uid://dhfplan3lkxas")

var _progress := 0.0
var _tween: Tween


static func create() -> SpinSmoke:
	return preload("uid://i6qiojuqmpnm").instantiate()


func _ready() -> void:
	z_index = GameConstants.Layers.Z_PARTICLES
	_tween = create_tween()
	_tween.tween_property(self, "_progress", 1, _LENGTH)


func _process(_delta: float) -> void:
	if not _tween.is_running() and not %Sound.playing and not is_playing():
		queue_free()
	queue_redraw()


func _draw() -> void:
	if not _tween.is_running():
		return
	for x in range(-32, 33, 64):
		for y in range(-16, 17, 32):
			var pos = -_STAR.get_size() / 2 + (Vector2(x, y) * _progress)
			draw_texture(_STAR, pos)
