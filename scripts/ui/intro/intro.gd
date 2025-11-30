@tool
class_name Intro
extends Control
## The intro scene.

var background = load("uid://chxg81fg1vwfv") as Texture2D
var anim: Node
var timer: SceneTreeTimer
var tween: Tween
var weekday: String
var player: AnimationPlayer
var skipped := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var path
	match Time.get_date_dict_from_system().weekday:
		1:
			weekday = tr("CALENDAR_MONDAY")
			path = "uid://brbx1wivbstu6"
		2:
			weekday = tr("CALENDAR_TUESDAY")
			path = "uid://brbx1wivbstu6"
		3:
			weekday = tr("CALENDAR_WEDNESDAY")
			path = "uid://bsxujjyxpynda"
		4:
			weekday = tr("CALENDAR_THURSDAY")
			path = "uid://brbx1wivbstu6"
		5:
			weekday = tr("CALENDAR_FRIDAY")
			path = "uid://bsxujjyxpynda"
		6:
			weekday = tr("CALENDAR_SATURDAY")
			path = "uid://bsxujjyxpynda"
		0:
			weekday = tr("CALENDAR_SUNDAY")
			path = "uid://brbx1wivbstu6"
	anim = (load(path) as PackedScene).instantiate()
	%AnimContainer.add_child(anim)
	player = anim.get_node("AnimationPlayer") as AnimationPlayer
	timer = get_tree().create_timer(1.5)
	timer.timeout.connect(_play_animation)


func _draw() -> void:
	var ratio = float(background.get_width()) / float(background.get_height())
	var step = size.y * ratio
	var bg_scale = size.y / float(background.get_height())
	var width = ceilf(size.x / step) * step
	var i = (size.x - width) / 2
	while i < size.x:
		draw_texture_rect(
				background,
				Rect2(Vector2(i, 0),
				background.get_size() * bg_scale),
				false
		)
		i += step


func _input(event: InputEvent) -> void:
	
	if (
			((event is InputEventAction and event.is_action_pressed("ui_accept"))
			or (event is InputEventScreenTouch and event.pressed))
			and not SceneManager.fade_in_progress()
	):
		_skip()
	if SceneManager.fade_in_progress():
		return
	if event.is_action_pressed("ui_accept"):
		_skip()
	if event is InputEventScreenTouch and event.pressed == true:
		_skip()


func _play_animation() -> void:
	player.play("animation")
	player.advance(0)
	player.animation_finished.connect(_finish_intro)


func _finish_intro(_anim_name: StringName) -> void:
	%Weekday.text = weekday
	tween = create_tween()
	tween.tween_property(%Logo, "position:y", 81, 1) \
			.set_trans(Tween.TRANS_BOUNCE) \
			.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(%Calendar, "modulate", Color.WHITE, 0.5)
	tween.tween_callback(_title_call)
	tween.tween_interval(3.9)
	tween.tween_property(%Calendar, "modulate", Color(Color.WHITE, 0), 0.5)
	tween.tween_callback(_skip)


func _title_call() -> void:
	UISoundPlayer.stream = load("uid://d384dtx16muau")
	UISoundPlayer.play()


func _skip() -> void:
	if skipped:
		return
	skipped = true
	UISoundPlayer.stop()
	%IntroFinishSound.play()
	
	# kill everything in progress
	anim.queue_free()
	if timer != null:
		timer.timeout.disconnect(_play_animation)
	if tween != null:
		tween.kill()
	
	# prepare final UI
	%Background.hide()
	%Calendar.hide()
	%Logo.position.y = 81
	%Logo.white = true
	%UI.show()
	
	# fade in UI
	var ui_tween = create_tween()
	ui_tween.tween_property(%UI, "modulate", Color.WHITE, 0.5) \
			.from(Color(Color.WHITE, 0))
