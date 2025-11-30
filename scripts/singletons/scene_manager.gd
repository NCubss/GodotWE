extends CanvasLayer
## Manages scene transitions.

## Represents a scene transition type.
enum Transition {
	## The scene fades in or out for [code]0.5[/code] seconds.
	FADE,
	## The scene is transitioned by a growing or shrinking circle for
	## [code]1[/code] second.
	CIRCLE
}

var _enter_tween: Tween
var _fade_tween: Tween
var _color_rect: ColorRect
var _progress := 1.0
var _active := false
var _material: ShaderMaterial

func _init() -> void:
	layer = RenderingServer.CANVAS_LAYER_MAX
	_color_rect = ColorRect.new()
	add_child(_color_rect)
	_color_rect.color = Color(Color.BLACK, 0)
	_color_rect.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT, true)
	_material = ShaderMaterial.new()
	_material.shader = preload("uid://euyudj0kkdr6")
	_material.set_shader_parameter("center", Vector2(0.5, 0.5))
	_color_rect.material = _material
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	_material.set_shader_parameter("size", _color_rect.size)
	_material.set_shader_parameter("active", _active)
	# compute the shit outside the shader so it doesn't have to calculate it
	# every frame
	if _active:
		var ratio = Vector2(_color_rect.size.x / _color_rect.size.y, 1)
		var smoothness = (ratio / _color_rect.size).dot(Vector2.ONE)
		var center: Vector2 = _material.get_shader_parameter("center")
		var max_tri = \
				Vector2(max(center.x, 1 - center.x), max(center.y, 1 - center.y))
		_material.set_shader_parameter("radius",
				((max_tri * ratio).length() + smoothness) * _progress)
		_material.set_shader_parameter("smoothness", smoothness)


func _enter_tree() -> void:
	_color_rect.color = Color.BLACK
	_enter_tween = create_tween()
	_enter_tween.tween_property(_color_rect, "color:a", 0.0, 0.5) \
			.from(1.0)
	#_enter_tween.tween_method(
			#func(x): _color_rect.material.set_shader_parameter("progress", x),
			#0.0, 1.0, 1)
	#_enter_tween.tween_callback(
			#_color_rect.material.set_shader_parameter.bind("progress", 0))
	#_enter_tween.tween_property(_color_rect, "color:a", 0, 0)


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
			_fade_tween.tween_property(_color_rect, "color:a", 1.0, 0.5)
		Transition.CIRCLE:
			_fade_tween.tween_property(self, "_active", true, 0)
			_fade_tween.tween_property(_color_rect, "color:a", 1.0, 0)
			#_fade_tween.tween_method(_set_progress, 1.0, 0.0, 1)
			_fade_tween.tween_property(self, "_progress", 0, 1).from(1)
			_fade_tween.tween_property(self, "_active", false, 0)
	_fade_tween.tween_callback(_change_scene.bind(scene))
	match trans_out:
		Transition.FADE:
			_fade_tween.tween_property(_color_rect, "color:a", 0.0, 0.5)
		Transition.CIRCLE:
			_fade_tween.tween_property(self, "_active", true, 0)
			#_fade_tween.tween_method(_set_progress, 0.0, 1.0, 1)
			_fade_tween.tween_property(self, "_progress", 1, 1).from(0)
			#_fade_tween.tween_callback(_set_progress.bind(0.0))
			_fade_tween.tween_property(self, "_progress", 0, 0)
			_fade_tween.tween_property(_color_rect, "color:a", 0.0, 0)
			_fade_tween.tween_property(self, "_active", false, 0)


func _change_scene(scene: PackedScene) -> void:
	get_tree().unload_current_scene()
	var scn = scene.instantiate()
	get_tree().root.add_child(scn)
	get_tree().current_scene = scn
