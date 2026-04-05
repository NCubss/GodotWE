extends CanvasLayer
## Manages scene transitions.

## Represents a scene transition type.
enum Transition {
	## No transition, so it is instant.
	NONE,
	## The scene fades in or out for half a second.
	FADE,
	## The scene is transitioned by a growing or shrinking circle for 1 second.
	CIRCLE
}

signal transition_started
signal transition_ended

## The transition used once the game starts.
const STARTING_TRANSITION = Transition.FADE
## The circle transition polygon's vertex count.
const CIRCLE_DETAIL = 64

var _enter_tween: Tween
var _fade_tween: Tween
var _color_rect := ColorRect.new()
var _polygon := Polygon2D.new()
var _points := PackedVector2Array()

func _init() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_color_rect.color = Color(Color.BLACK, 0)
	_color_rect.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT, true)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_color_rect)
	
	_polygon.color = Color.BLACK
	_polygon.invert_enabled = true
	_polygon.hide()
	for i in CIRCLE_DETAIL:
		var rad = TAU * i / CIRCLE_DETAIL
		_points.append(Vector2(sin(rad), cos(rad)))
	add_child(_polygon)


func _ready() -> void:
	_polygon.invert_border = max(_color_rect.size.x, _color_rect.size.y)
	match STARTING_TRANSITION:
		Transition.NONE:
			pass
		Transition.FADE:
			_color_rect.color.a = 1
			_enter_tween = create_tween()
			_enter_tween.tween_property(_color_rect, "color:a", 0, 0.5).from(1)
		Transition.CIRCLE:
			_polygon.show()
			_enter_tween = create_tween()
			_enter_tween.tween_method(_update_polygon, 0.0, 1.0, 1) \
					.set_trans(Tween.TRANS_SINE) \
					.set_ease(Tween.EASE_IN)
			_enter_tween.tween_callback(_polygon.hide)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F11:
			if get_window().mode == Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_WINDOWED
			elif get_window().mode == Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_FULLSCREEN


func fade_to(
		path: String,
		trans_in := Transition.FADE,
		trans_out := Transition.FADE
) -> void:
	
	var scn = load(path) as PackedScene
	if scn == null:
		assert(false, "Resource at path '%s' does not exist or is not a scene" \
				% path)
		return
	_fade_to_what(load(path), trans_in, trans_out)


func fade_to_scene(
		scene: PackedScene,
		trans_in := Transition.FADE,
		trans_out := Transition.FADE
) -> void:
	_fade_to_what(scene, trans_in, trans_out)


func fade_in_progress() -> bool:
	return (_enter_tween.is_running() if _enter_tween != null else false) \
			or (_fade_tween.is_running() if _fade_tween != null else false)


func _fade_to_what(
		scene: PackedScene,
		trans_in: Transition,
		trans_out: Transition
) -> void:
	if not scene.can_instantiate():
		assert(false, "Empty scene")
		return
	_fade_tween = create_tween()
	transition_started.emit()
	match trans_in:
		Transition.NONE:
			pass
		Transition.FADE:
			_fade_tween.tween_property(_color_rect, "color:a", 1, 0.5).from(0)
			_fade_tween.tween_property(_color_rect, "color:a", 0, 0)
		Transition.CIRCLE:
			_fade_tween.tween_callback(_polygon.show)
			_fade_tween.tween_method(_update_polygon, 1.0, 0.0, 1) \
					.set_trans(Tween.TRANS_SINE) \
					.set_ease(Tween.EASE_IN)
			_fade_tween.tween_callback(_polygon.hide)
	_fade_tween.tween_callback(_change_scene.bind(scene.instantiate()))
	match trans_out:
		Transition.NONE:
			pass
		Transition.FADE:
			_fade_tween.tween_property(_color_rect, "color:a", 0, 0.5).from(1)
		Transition.CIRCLE:
			_fade_tween.tween_callback(_polygon.show)
			_fade_tween.tween_method(_update_polygon, 0.0, 1.0, 1) \
					.set_trans(Tween.TRANS_SINE) \
					.set_ease(Tween.EASE_IN)
			_fade_tween.tween_callback(_polygon.hide)
	_fade_tween.tween_callback(transition_ended.emit)


func _change_scene(scene: Node) -> void:
	get_tree().unload_current_scene()
	Utility.camera_scale = Vector2(1, 1)
	Utility.camera_position = Vector2(0, 0)
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	get_tree().scene_changed.emit()


func _update_polygon(progress: float) -> void:
	var radius = _color_rect.size.length() * progress / 2.0
	_polygon.polygon = Transform2D(0, Vector2(radius, radius), 0, Vector2(0, 0))\
			* _points
	_polygon.position = _color_rect.size / 2
