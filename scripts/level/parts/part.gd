class_name Part
extends Area2D
## A gameplay element in a [Level].
## 
## [Part]s are what [SubArea]s are made of. They represent gameplay elements,
## which parts generate on request via [method build]. In SMM:WE this can be
## seen as an equivalent to [code]obj_parent_resource[/code].

const _TOP_Z = 55

## The matching [PartInfo] for this part.
@export var part_info: PartInfo

var level: Level
var sub_area: SubArea
## Whether this part is currently being dragged around.
var held := false:
	set(value):
		if held == value:
			return
		held = value
		queue_redraw()
		if value:
			_hold()
		else:
			_unhold()

# Tween used for the held and placing animations.
var _tween: Tween
# The mouse position relative to the part while held. Used for determining the
# part position while being held.
var _grab_offset: Vector2
# The last calculated grid position. Used for checking when the user hovers over
# a different grid spot.
var _grid_pos: Vector2i
# Whether the hovered grid tile is free to place the held part on.
var _valid_space: bool = true
# The original grid spot this part was on prior to being held.
var _original_pos: Vector2i
var _original_z: int
# Whether the mouse is currently hovering over this part.
var _mouse_in: bool
# Whether the part has been moved out of its original position while held. Used
# to check when a variant window should be opened or closed.
var _moved_out: bool
# The process tick this part was spawned on. Used to prevent the part being
# immediately held once placed. (I'm sure there's a better way to handle this.)
var _start_frame := Engine.get_process_frames()
var _coll_layers: int
var _window: EditorWindow
var _window_timer: SceneTreeTimer

## This part's graphics node.
@onready var graphics: Node2D = $Graphics


func _ready() -> void:
	mouse_entered.connect(_mouse_update.bind(true))
	mouse_exited.connect(_mouse_update.bind(false))
	_grid_pos = level.to_grid(global_position)
	_anim_place()


func _process(_delta: float) -> void:
	if held:
		queue_redraw()
		global_position = get_global_mouse_position() - _grab_offset
		var new_grid_pos = level.to_grid(global_position + Vector2(8, 8))
		if new_grid_pos != _grid_pos:
			# choosing which sound to play
			var sound = preload("uid://rlah407gh46u")
			if _moved_out == false:
				_moved_out = true
				_stop_window_timer()
				if _window != null:
					_window.close()
				sound = preload("uid://b87gjrl17xs2k")
			if not UISoundPlayer.playing:
				UISoundPlayer.stream = sound
				UISoundPlayer.play()
			_check_validity()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
		return
	if not event.pressed:
		held = false


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if Engine.get_process_frames() == _start_frame:
		return
	if event is not InputEventMouseButton:
		return
	if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		held = true
	elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and not held:
		erase()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and held:
		level.editor.held_part = null


func _draw():
	if is_queued_for_deletion():
		return
	var rect = Rect2(level.from_grid(_grid_pos) - position,
			level.from_grid(part_info.size))
	if held:
		var color
		if _valid_space:
			color = Color(0, 0, 1, 0.5)
		else:
			color = Color(1, 0, 0, 0.5)
		draw_rect(rect, color)
	elif _mouse_in and level.editor.can_interact:
		rect.position -= global_position
		draw_rect(rect, Color(0, 0, 1, 0.5))


func erase() -> void:
	queue_free()
	UISoundPlayer.stream = preload("uid://2axkkfi5xrx8")
	UISoundPlayer.play()


func build() -> void:
	pass


func _anim_place() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(graphics, "scale", Vector2(1, 1), 0.1) \
			.from(Vector2(0.1, 0.1))


func _anim_held() -> void:
	_tween = graphics.create_tween().set_trans(Tween.TRANS_SINE)
	_tween.tween_property(graphics, "rotation", TAU / 30, 0.2).from(0) \
			.set_ease(Tween.EASE_OUT)
	_tween.tween_property(graphics, "rotation", TAU / -30, 0.4) \
			.set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(graphics, "rotation", 0, 0.2) \
			.set_ease(Tween.EASE_IN)
	_tween.set_loops()


func _mouse_update(state: bool) -> void:
	_mouse_in = state
	queue_redraw()
	if _mouse_in:
		level.editor.hovered_part = self
		if level.editor.erasing and not held:
			erase()
	elif level.editor.hovered_part == self:
		level.editor.hovered_part = null


func _hold() -> void:
	_coll_layers = collision_layer
	collision_layer = 0
	_original_pos = _grid_pos
	_original_z = graphics.z_index
	graphics.z_index = _TOP_Z
	level.editor.held_part = self
	_window_timer = get_tree().create_timer(0.5)
	_window_timer.timeout.connect(_create_window)
	_anim_held()
	if level.editor.touch_effect == null:
		level.editor.touch_effect = preload("uid://chv4mkls3f538") \
				.instantiate()
		level.editor.touch_effect.animation_finished.connect(
				level.editor.touch_effect.queue_free)
		level.add_child(level.editor.touch_effect)
		level.editor.touch_effect.global_position = get_global_mouse_position()
	_grab_offset = get_global_mouse_position() - global_position
	_moved_out = false
	UISoundPlayer.stream = preload("uid://cjtdcx7crghtw")
	UISoundPlayer.play()


func _unhold() -> void:
	collision_layer = _coll_layers
	graphics.z_index = _original_z
	level.editor.held_part = null
	_tween.kill()
	_anim_place()
	_check_validity()
	_stop_window_timer()
	if not _valid_space:
		_grid_pos = _original_pos
	position = level.from_grid(_grid_pos)
	graphics.rotation = 0
	UISoundPlayer.stream = preload("uid://2x6kk0s4njjp")
	UISoundPlayer.play()


func _check_validity():
	_grid_pos = level.to_grid(level.get_local_mouse_position())
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1 << 8
	query.exclude = [get_rid()]
	query.position = level.from_grid(_grid_pos) + level.GRID_SIZE / 2
	_valid_space = get_world_2d().direct_space_state \
			.intersect_point(query, 1).is_empty()


func _create_window() -> void:
	_window = preload("uid://dyw1evq8k8n58").instantiate()
	_window.target_position = level.from_grid(_original_pos) + level.GRID_SIZE / 2
	level.editor.get_node(^"%WindowLayer").add_child(_window)


func _stop_window_timer() -> void:
	if _window_timer != null:
		if _window_timer.timeout.is_connected(_create_window):
			_window_timer.timeout.disconnect(_create_window)
