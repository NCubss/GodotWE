class_name EraserBtn
extends BaseButton

const IDLE_TEXTURE = preload("uid://ckascx1aanog8")
const JUMP_TEXTURE = preload("uid://dve0443qo0gaj")
const JUMP_SOUND = preload("uid://b2hqn5k2lsyk6")
const DUCK_TEXTURE = preload("uid://boy2ksuiu4eud")
const DUCK_SOUND = preload("uid://c6fvx6uwc8xga")
const HOVER_SOUND = preload("uid://bbc6fa1b5njqq")
const DELAY = 5/12.0

var texture := IDLE_TEXTURE
var tween: Tween

@onready var effect := ButtonHoverEffect.new(self)


func _ready() -> void:
	%Editor.erase_started.connect(_erase_started)
	%Editor.erase_stopped.connect(_erase_stopped)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func _process(_delta: float) -> void:
	effect.check_redraw()


func _draw() -> void:
	draw_texture(texture, Vector2(0, -9))
	effect.draw()


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		%Editor.erasing = Editor.EraseMode.TOGGLE_ERASE
	else:
		%Editor.erasing = Editor.EraseMode.NONE


func _erase_started() -> void:
	set_pressed_no_signal(true)
	
	if tween != null and tween.is_valid():
		return
	tween = create_tween()
	tween.set_loops()
	
	tween.tween_property(self, ^"texture", JUMP_TEXTURE, 0)
	tween.tween_callback(queue_redraw)
	# fun way of doing it
	tween.tween_property(%EraserSounds, ^"stream", JUMP_SOUND, 0)
	tween.tween_callback(%EraserSounds.play)
	tween.tween_interval(DELAY)
	
	tween.tween_property(self, ^"texture", DUCK_TEXTURE, 0)
	tween.tween_callback(queue_redraw)
	tween.tween_property(%EraserSounds, ^"stream", DUCK_SOUND, 0)
	tween.tween_callback(%EraserSounds.play)
	tween.tween_interval(DELAY)


func _erase_stopped() -> void:
	set_pressed_no_signal(false)
	tween.kill()
	texture = IDLE_TEXTURE
	queue_redraw()


func _mouse_entered() -> void:
	UISoundPlayer.stream = HOVER_SOUND
	UISoundPlayer.play()
	effect.start()


func _mouse_exited() -> void:
	effect.stop()
