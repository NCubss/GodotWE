extends CanvasModulate

var _enter_tween: Tween
var _fade_tween: Tween
#var _canvas_layer: CanvasLayer
#var _color_rect: ColorRect
#
#func _init() -> void:
	#_canvas_layer = CanvasLayer.new()
	#_canvas_layer.layer = RenderingServer.CANVAS_LAYER_MAX
	#_color_rect = ColorRect.new()
	#add_child(_canvas_layer)
	#_canvas_layer.add_child(_color_rect)
	#_color_rect.set_anchors_preset(Control.LayoutPreset.PRESET_FULL_RECT, true)


func _enter_tree() -> void:
	_enter_tween = create_tween()
	_enter_tween.tween_property(self, "color", Color.WHITE, 0.5) \
			.from(Color.BLACK)


func fade_to(path: String) -> void:
	_fade_to_what(load(path))


func fade_to_scene(scene: PackedScene) -> void:
	_fade_to_what(scene)


func fade_in_progress() -> bool:
	return (_enter_tween.is_running() if _enter_tween != null else false) \
			or (_fade_tween.is_running() if _fade_tween != null else false)


func _fade_to_what(scene: PackedScene) -> void:
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "color", Color.BLACK, 0.5)
	_fade_tween.tween_callback(_change_scene.bind(scene))
	_fade_tween.tween_property(self, "color", Color.WHITE, 0.5)


func _change_scene(scene: PackedScene) -> void:
	get_tree().unload_current_scene()
	var scn = scene.instantiate()
	get_tree().root.add_child(scn)
	get_tree().current_scene = scn
