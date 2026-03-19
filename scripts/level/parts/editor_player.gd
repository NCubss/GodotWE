class_name EditorPlayer
extends Part

var player: Player

const SPEED = 240.0


func _process(delta: float) -> void:
	super(delta)
	if level.status == Level.Status.EDITING:
		var speed = Vector2(
				Input.get_axis(&"player_left", &"player_right") * SPEED,
				Input.get_axis(&"player_up", &"player_down") * SPEED)
		var camera_area = level.editor.get_node(^"%CameraArea")
		var area: Rect2 = camera_area.get_global_transform_with_canvas() \
				* Rect2(Vector2(0, 0), camera_area.size)
		var me: Rect2 = get_global_transform_with_canvas() * Rect2(0, 0, 16, 16)
		if me.position.x >= area.position.x and me.end.x <= area.end.x:
			Utility.camera_position.x += speed.x * Utility.camera_scale.x * delta
		var height = 16 * Utility.camera_scale.y
		if (speed.y < 0 and me.end.y <= area.position.y + height) \
				or (speed.y > 0 and me.position.y >= area.end.y - height):
			Utility.camera_position.y += speed.y * Utility.camera_scale.y * delta
		position += speed * delta
	elif player != null:
		position = player.position - Vector2(8, 16)
	position = position.clamp(
			Vector2(0, -Level.LEVEL_HEIGHT * Level.GRID_SIZE.y),
			Vector2(INF, -16))


func _draw():
	if level == null:
		return
	if is_queued_for_deletion():
		return
	var rect: Rect2
	if held:
		rect = Rect2(level.from_grid(_grid_pos) - position, level.GRID_SIZE)
		var color
		if _valid_space:
			color = Color(0, 0, 1, 0.5)
		else:
			color = Color(1, 0, 0, 0.5)
		draw_rect(rect, color)
	elif _mouse_in and level.editor.part_interact:
		rect = Rect2(position, level.GRID_SIZE)
		rect.position -= global_position
		draw_rect(rect, Color(0, 0, 1, 0.5))


func build() -> void:
	player = preload("uid://b2cwk2viytb57").instantiate()
	player.position = position + Vector2(8, 16)
	player.level = level
	sub_area.get_foreground().add_child(player)


func erase(_silent := false) -> void:
	pass


func _check_validity() -> void:
	_grid_pos = level.to_grid(level.get_local_mouse_position())
	_valid_space = true
