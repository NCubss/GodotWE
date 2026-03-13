@tool
class_name SmoothScrollContainer
extends Container

const MOUSE_SCROLL_SPEED = 600.0
const MOUSE_ADDITIVE_SCROLL_SPEED = 200.0
const MOUSE_DECEL = 120.0
const TOUCH_DECEL = 60.0

var speed := Vector2.ZERO
var scroll_value := Vector2.ZERO

var _touch_velocity: Vector2
var _touching := false
var _touch_pos: Vector2
var _decel := MOUSE_DECEL


func _init() -> void:
	clip_contents = true


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		var box = get_theme_stylebox("panel")
		var pos = Vector2.ZERO
		var end = Vector2.ZERO
		if box != null:
			pos = Vector2(box.get_margin(SIDE_LEFT),
					box.get_margin(SIDE_TOP))
			end = Vector2(box.get_margin(SIDE_RIGHT),
					box.get_margin(SIDE_BOTTOM))
		for i: Control in get_children():
			i.position = pos - scroll_value
			i.size = size - pos - end


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	scroll_value += speed * delta
	scroll_value = scroll_value.clamp(get_scroll_min(), get_scroll_max())
	speed = speed.move_toward(Vector2.ZERO, _decel)
	notification(NOTIFICATION_SORT_CHILDREN)


func get_scroll_min() -> Vector2:
	return Vector2.ZERO


func get_scroll_max() -> Vector2:
	var result = Vector2.INF
	for i in get_children():
		result = result.min(i.size)
	return result - _get_marginless_rect().size


func _get_marginless_rect() -> Rect2:
	var box = get_theme_stylebox("panel")
	return get_rect().grow_individual(
			-box.get_margin(SIDE_LEFT),
			-box.get_margin(SIDE_TOP),
			-box.get_margin(SIDE_RIGHT),
			-box.get_margin(SIDE_BOTTOM))


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_decel = MOUSE_DECEL
				speed.y = min(speed.y - MOUSE_ADDITIVE_SCROLL_SPEED,
						-MOUSE_SCROLL_SPEED)
			MOUSE_BUTTON_WHEEL_DOWN:
				_decel = MOUSE_DECEL
				speed.y = max(speed.y + MOUSE_ADDITIVE_SCROLL_SPEED,
						MOUSE_SCROLL_SPEED)
			MOUSE_BUTTON_LEFT:
				if DisplayServer.is_touchscreen_available():
					_decel = TOUCH_DECEL
					_touching = event.pressed
					#var box = get_theme_stylebox("panel")
					_touch_pos = event.position - global_position \
							 + scroll_value
					if not _touching:
						speed = _touch_velocity
					else:
						speed = Vector2.ZERO
						_touch_velocity = Vector2.ZERO
	elif event is InputEventMouseMotion:
		if DisplayServer.is_touchscreen_available():
			_decel = TOUCH_DECEL
			_touch_velocity = -event.velocity * 1.5
			if _touching:
				scroll_value = _touch_pos - event.position - global_position


func _draw() -> void:
	draw_style_box(get_theme_stylebox("panel"), get_rect())
