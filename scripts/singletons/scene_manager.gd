extends CanvasLayer
## Manages scene transitions.

## Represents a scene transition type.
enum Transition {
	## The scene fades in or out for half a second.
	FADE,
	## The scene is transitioned by a growing or shrinking circle for 1 second.
	CIRCLE
}

## The transition used once the game starts.
const STARTING_TRANSITION = Transition.FADE
## The circle transition polygon's vertex count.
const CIRCLE_DETAIL = 64

var _enter_tween: Tween
var _fade_tween: Tween
var _color_rect := ColorRect.new()
var _polygon := Polygon2D.new()
var _max_radius: float

func _init() -> void:
	layer = RenderingServer.CANVAS_LAYER_MAX
	
	_color_rect.color = Color(Color.BLACK, 0)
	_color_rect.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT, true)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_color_rect)
	
	_polygon.color = Color.BLACK
	_polygon.invert_enabled = true
	_polygon.hide()
	add_child(_polygon)


func _ready() -> void:
	var screen_size = _color_rect.size
	_max_radius = screen_size.length() / 2
	_polygon.invert_border = max(screen_size.x, screen_size.y)
	_polygon.position = screen_size / 2
	match STARTING_TRANSITION:
		Transition.FADE:
			_color_rect.color.a = 1
			_enter_tween = create_tween()
			_enter_tween.tween_property(_color_rect, "color:a", 0, 0.5).from(1)
		Transition.CIRCLE:
			_polygon.show()
			_enter_tween = create_tween()
			_enter_tween.tween_method(_update_polygon, 0,
					screen_size.length() / 2, 1) \
					.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			_enter_tween.tween_callback(_polygon.hide)


func fade_to(
		path: String,
		trans_in := Transition.FADE,
		trans_out := Transition.FADE
) -> void:
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
	_fade_tween = create_tween()
	match trans_in:
		Transition.FADE:
			_fade_tween.tween_property(_color_rect, "color:a", 1, 0.5).from(0)
			_fade_tween.tween_property(_color_rect, "color:a", 0, 0)
		Transition.CIRCLE:
			_fade_tween.tween_callback(_polygon.show)
			_fade_tween.tween_method(_update_polygon, \
					_color_rect.size.length() / 2, 0, 1)
			_fade_tween.tween_callback(_polygon.hide)
	_fade_tween.tween_callback(_change_scene.bind(scene.instantiate()))
	match trans_out:
		Transition.FADE:
			_fade_tween.tween_property(_color_rect, "color:a", 0, 0.5).from(1)
		Transition.CIRCLE:
			_fade_tween.tween_callback(_polygon.show)
			_fade_tween.tween_method(_update_polygon, \
					0, _color_rect.size.length() / 2, 1)
			_fade_tween.tween_callback(_polygon.hide)


func _change_scene(scene: Node) -> void:
	get_tree().unload_current_scene()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene


func _update_polygon(radius: float) -> void:
	var data = PackedVector2Array()
	for i in range(CIRCLE_DETAIL):
		var val = TAU * i / CIRCLE_DETAIL
		data.append(Vector2(sin(val) * radius, cos(val) * radius))
	_polygon.polygon = data
