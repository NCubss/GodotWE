class_name Part
extends Area2D

## The [TileComponent] of this part. If the part does not contain a
## [TileComponent], the part will not check for existing tiles in new positions
## and will allow overlapping, as it can't be part of the [Map] without a
## [TileComponent].
@onready var tile_comp = Utility.find_child_by_class(self, TileComponent)
## This part's graphics node.
@onready var graphics: Node2D = $Graphics
@onready var _editor: Editor = Utility.id("editor")
@onready var _map: Map = Utility.id("editor_map")
@onready var _coll_shape: CollisionShape2D = Utility.find_child_by_class(
		self, CollisionShape2D)
var _original_z: int
const _TOP_Z = 55

## Whether this part is currently being dragged around.
var held := false:
	set(value):
		if held == value:
			return
		held = value
		if value:
			queue_redraw()
			if tile_comp != null:
				_original_pos = tile_comp.position
				tile_comp.map_disconnect()
			else:
				_original_pos = _map.coords(global_position)
			_original_z = graphics.z_index
			graphics.z_index = _TOP_Z
			_editor.held_part = self
			_tween = graphics.create_tween().set_trans(Tween.TRANS_SINE)
			_tween.tween_property(graphics, "rotation", TAU / 30, 0.2).from(0) \
					.set_ease(Tween.EASE_OUT)
			_tween.tween_property(graphics, "rotation", TAU / -30, 0.4) \
					.set_ease(Tween.EASE_IN_OUT)
			_tween.tween_property(graphics, "rotation", 0, 0.2) \
					.set_ease(Tween.EASE_IN)
			_tween.set_loops()
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
		else:
			queue_redraw()
			graphics.z_index = _original_z
			Utility.id("editor").held_part = null
			_tween.kill()
			place_anim()
			graphics.rotation = 0
			if tile_comp != null:
				_map.set_tile(
						_grid_pos if _valid_space else _original_pos, self)
			else:
				global_position = Vector2(_grid_pos) * _map.tile_size
			UISoundPlayer.stream = load("uid://2x6kk0s4njjp")
			UISoundPlayer.play()

var _tween: Tween
var _grab_offset: Vector2
var _grid_pos: Vector2i
var _valid_space: bool
var _original_pos: Vector2i
var _mouse_in: bool
var _moved_out: bool


func _ready() -> void:
	mouse_entered.connect(_mouse_update.bind(true))
	mouse_exited.connect(_mouse_update.bind(false))
	place_anim()


func _mouse_update(state: bool) -> void:
	_mouse_in = state
	if _mouse_in:
		_editor.hovered_part = self
		if _editor.erasing:
			queue_free()
			UISoundPlayer.stream = load("uid://2axkkfi5xrx8")
			UISoundPlayer.play()
	elif _editor.hovered_part == self:
		_editor.hovered_part = null


func place_anim() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(graphics, "scale", Vector2(1, 1), 0.1) \
			.from(Vector2(0.1, 0.1))


func _process(_delta: float) -> void:
	if not is_node_ready():
		return
	if held:
		global_position = get_global_mouse_position() - _grab_offset
	queue_redraw()
	var new_grid_pos = _map.coords(_coll_shape.global_position)
	if new_grid_pos != _grid_pos and held and not UISoundPlayer.playing:
		var path = "uid://rlah407gh46u"
		if _moved_out == false:
			_moved_out = true
			path = "uid://b87gjrl17xs2k"
		UISoundPlayer.stream = load(path)
		UISoundPlayer.play()
	_grid_pos = new_grid_pos
	if tile_comp != null:
		_valid_space = _map.get_tile(_grid_pos) == null
	else:
		_valid_space = true


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
		return
	if not event.pressed:
		held = false


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton:
		return
	match event.button_index:
		MouseButton.MOUSE_BUTTON_LEFT:
			held = event.pressed and _mouse_in and _editor.held_part == null and not held
		MouseButton.MOUSE_BUTTON_RIGHT:
			queue_free()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			if held:
				_editor.held_part = null


func _draw():
	if held or (_mouse_in and Utility.id("editor").held_part == null):
		draw_rect(Rect2(
				(Vector2(_grid_pos) * get_parent().tile_size) - global_position,
				get_parent().tile_size),
				Color(0, 0, 1, 0.5) if _valid_space or not held else Color(1, 0, 0, 0.5))
