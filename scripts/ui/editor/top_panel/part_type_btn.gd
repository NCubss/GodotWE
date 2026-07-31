class_name PartTypeBtn
extends TextureButton

const BTN_OBJECTS = preload("uid://cjt6vqgprv8fg")
const BTN_OBJECTS_BLINK = preload("uid://b2v0fhgpg8w8x")
const BTN_SOUNDS = preload("uid://bm1dqxydc2yy7")
const BTN_SOUNDS_OPEN = preload("uid://cghxg8d80ngy")
const QUAVER = preload("uid://dj3wb3bwkypgx")
const DOUBLE_QUAVER = preload("uid://p7m6sps4hjc1")


var timer := Timer.new()
var sounds := AudioStreamPlayer.new()

var _tween: Tween
var _quaver_pos := Vector2.INF
var _double_quaver_pos := Vector2.INF

@onready var effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	sounds.name = "Sounds"
	add_child(sounds)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	timer.name = "AnimationTimer"
	timer.one_shot = true
	add_child(timer)
	# trigger animation
	if button_pressed:
		_animate_sounds()
	else:
		_animate_objects()


func _process(_delta: float) -> void:
	effect.check_redraw()
	if _tween != null and _tween.is_valid():
		queue_redraw()


func _draw() -> void:
	draw_texture(QUAVER, _quaver_pos)
	draw_texture(DOUBLE_QUAVER, _double_quaver_pos)
	effect.draw()


func _toggled(toggled_on: bool) -> void:
	sounds.stream = preload("uid://dyyn2nvxnwepp")
	sounds.play()
	if toggled_on:
		_animate_sounds()
	else:
		_animate_objects()


func _animate_objects() -> void:
	texture_normal = BTN_OBJECTS
	if _tween != null:
		_tween.kill()
		_quaver_pos = Vector2.INF
		_double_quaver_pos = Vector2.INF
	timer.stop()
	timer.timeout.emit()
	timer.start(2)
	while not button_pressed:
		await timer.timeout
		match texture_normal:
			BTN_OBJECTS:
				texture_normal = BTN_OBJECTS_BLINK
				timer.start(1/6.0)
			BTN_OBJECTS_BLINK:
				texture_normal = BTN_OBJECTS
				timer.start(randf_range(2, 4))


func _animate_sounds() -> void:
	texture_pressed = BTN_SOUNDS
	timer.stop()
	timer.timeout.emit()
	timer.start(1/9.0)
	while button_pressed:
		await timer.timeout
		match texture_pressed:
			BTN_SOUNDS:
				texture_pressed = BTN_SOUNDS_OPEN
				timer.start(6/9.0)
				_animate_quavers()
			BTN_SOUNDS_OPEN:
				texture_pressed = BTN_SOUNDS
				timer.start(1/9.0)


func _animate_quavers() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "_quaver_pos", Vector2(-3, -3), 3/9.0) \
			.from(Vector2(0, 3))
	_tween.tween_property(self, "_quaver_pos", Vector2.INF, 0)
	_tween.tween_property(self, "_double_quaver_pos", Vector2(51, 0), 3/9.0) \
			.from(Vector2(45, 6))
	_tween.tween_property(self, "_double_quaver_pos", Vector2.INF, 0)


func _mouse_entered() -> void:
	effect.start()


func _mouse_exited() -> void:
	effect.stop()
