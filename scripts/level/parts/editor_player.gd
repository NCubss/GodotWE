class_name EditorPlayer
extends Part

var player: Player

const SPEED = 128.0


func _process(delta: float) -> void:
	super(delta)
	if level.status == Level.Status.EDITING:
		var speed = Vector2(
				Input.get_axis(&"player_left", &"player_right") * SPEED,
				Input.get_axis(&"player_up", &"player_down") * SPEED)
		position += speed * delta
	else:
		position = player.position - Vector2(8, 16)


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


func _check_validity() -> void:
	_grid_pos = level.to_grid(level.get_local_mouse_position())
	_valid_space = true
