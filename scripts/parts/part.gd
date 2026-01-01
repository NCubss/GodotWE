class_name Part
extends Area2D

## The matching [PartInfo] for this part.
@export var part_info: PartInfo

## This part's graphics node.
@onready var graphics: Node2D = $Graphics
@onready var map: FastMap = Utility.id("editor_map")

@onready var _editor: Editor = Utility.id("editor")

const _TOP_Z = 55

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
var tile: Tile

var _tween: Tween
var _grab_offset: Vector2
# The last calculated grid position. Used for checking when the user hovers over
# a different grid spot.
var _grid_pos: Vector2i
var _valid_space: bool = true
var _original_pos: Vector2i
var _original_z: int
var _mouse_in: bool
var _moved_out: bool
var _start_frame := Engine.get_frames_drawn()


func _ready() -> void:
	mouse_entered.connect(_mouse_update.bind(true))
	mouse_exited.connect(_mouse_update.bind(false))
	_anim_place()


func _process(_delta: float) -> void:
	if held:
		queue_redraw()
		global_position = get_global_mouse_position() - _grab_offset
		var new_grid_pos = map.to_map_coords(
				global_position + (map.cell_size / 2))
		if new_grid_pos != _grid_pos:
			# choosing which sound to play
			var sound_path = "uid://rlah407gh46u"
			if _moved_out == false:
				_moved_out = true
				sound_path = "uid://b87gjrl17xs2k"
			if not UISoundPlayer.playing:
				UISoundPlayer.stream = load(sound_path)
				UISoundPlayer.play()
			_grid_pos = new_grid_pos
			_valid_space = map.is_area_free(Rect2i(_grid_pos, part_info.size))


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
		return
	if not event.pressed:
		held = false


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if Engine.get_frames_drawn() == _start_frame:
		return
	if event is not InputEventMouseButton:
		return
	if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		held = true
	elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT and not held:
		erase()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and held:
		_editor.held_part = null


func _draw():
	if is_queued_for_deletion():
		return
	if held:
		var rect = Rect2(map.to_global_coords(_grid_pos) - global_position,
				Vector2(part_info.size) * map.cell_size)
		var color
		if _valid_space:
			color = Color(0, 0, 1, 0.5)
		else:
			color = Color(1, 0, 0, 0.5)
		draw_rect(rect, color)
	elif _mouse_in and _editor.can_interact:
		var rect = tile.to_global_coords()
		rect.position -= global_position
		draw_rect(rect, Color(0, 0, 1, 0.5))


func erase() -> void:
	queue_free()
	if tile != null:
		tile.remove()
	UISoundPlayer.stream = load("uid://2axkkfi5xrx8")
	UISoundPlayer.play()


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
		_editor.hovered_part = self
		if _editor.erasing and not held:
			erase()
	elif _editor.hovered_part == self:
		_editor.hovered_part = null


func _hold() -> void:
	_original_pos = tile.rect.position
	_original_z = graphics.z_index
	tile.remove()
	tile = null
	graphics.z_index = _TOP_Z
	_editor.held_part = self
	_anim_held()
	if _editor._touch_effect == null:
		_editor._touch_effect = load("uid://chv4mkls3f538") \
				.instantiate()
		_editor._touch_effect.animation_finished.connect(
				_editor._touch_effect.queue_free)
		get_tree().current_scene.add_child(_editor._touch_effect)
		_editor._touch_effect.global_position = \
				get_global_mouse_position()
	_grab_offset = get_global_mouse_position() - global_position
	_moved_out = false
	UISoundPlayer.stream = load("uid://cjtdcx7crghtw")
	UISoundPlayer.play()


func _unhold() -> void:
	graphics.z_index = _original_z
	Utility.id("editor").held_part = null
	_tween.kill()
	_anim_place()
	graphics.rotation = 0
	tile = map.set_tile(self, Rect2i(_grid_pos if _valid_space else _original_pos, part_info.size))
	UISoundPlayer.stream = load("uid://2x6kk0s4njjp")
	UISoundPlayer.play()
