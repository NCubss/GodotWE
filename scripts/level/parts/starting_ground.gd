class_name StartingGround
extends Part

var _grabber_held := false
var _grabber_cooldown := 0.0

const COOLDOWN = 0.05

func _ready() -> void:
	%Graphics.set_script(GroundDrawer)
	%CollShape.shape.size.y = absf(position.y)
	%CollShape.position.y = position.y / -2


func _process(delta: float) -> void:
	if _grabber_cooldown < COOLDOWN:
		_grabber_cooldown += delta
	if _grabber_held and _grabber_cooldown >= COOLDOWN:
		var mouse_y = mini(-1, level.to_grid(get_global_mouse_position()).y)
		if mouse_y != _grid_pos.y:
			_grid_pos.y = floori(move_toward(_grid_pos.y, mouse_y, 1))
			position = level.from_grid(_grid_pos)
			%CollShape.shape.size.y = absf(position.y)
			%CollShape.position.y = position.y / -2
			var query = PhysicsShapeQueryParameters2D.new()
			query.shape = RectangleShape2D.new()
			query.shape.size = %CollShape.shape.size - Vector2(16, 16)
			query.transform = %CollShape.global_transform
			query.collide_with_areas = true
			query.collide_with_bodies = false
			query.exclude = [get_rid()]
			query.collision_mask = 1 << 8
			for i in get_world_2d().direct_space_state.intersect_shape(query):
				if i["collider"] is Part:
					i["collider"].erase(true)
			UISoundPlayer.stream = preload("uid://mtek8lrj63d5")
			UISoundPlayer.play()
			_grabber_cooldown = 0
			%Graphics.queue_redraw()


func _draw() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_grabber_held = false
			level.editor.part_interact = true


func erase(_silent := false) -> void:
	push_warning("Starting ground can't be erased.")


func build() -> void:
	var fore = sub_area.get_foreground()
	var start = Sprite2D.new()
	start.name = "StartArrow"
	start.texture = preload("uid://cgslc0o8upncx")
	start.position = position + Vector2(40, -24)
	start.z_as_relative = false
	fore.add_child(start)
	for x in range(0, 112, 16):
		for y in range(0, absi(floori(global_position.y)), 16):
			var atlas: Rect2
			if x == 96 and y == 0:
				atlas = Rect2(80, 0, 16, 16)
			elif x == 96:
				atlas = Rect2(80, 16, 16, 16)
			elif y == 0:
				atlas = Rect2(16, 0, 16, 16)
			else:
				atlas = Rect2(16, 16, 16, 16)
			var tile = preload("uid://bpy1sebdq7k7s").instantiate()
			tile.get_node(^"%Sprite").texture.region = atlas
			fore.add_child(tile)
			tile.position = position + Vector2(x, y)


func _hold() -> void:
	push_warning("Starting ground can't be held.")
	held = false


func _unhold() -> void:
	pass


func _on_grabber_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not level.editor.part_interact:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_grabber_held = true
			level.editor.part_interact = false


class GroundDrawer extends Node2D:
	const GROUND = preload("uid://clwe7seivxsur")
	
	
	func _draw() -> void:
		for x in range(0, 112, 16):
			for y in range(0, absi(floori(global_position.y)), 16):
				var atlas: Rect2
				if x == 96 and y == 0:
					atlas = Rect2(80, 0, 16, 16)
				elif x == 96:
					atlas = Rect2(80, 16, 16, 16)
				elif y == 0:
					atlas = Rect2(16, 0, 16, 16)
				else:
					atlas = Rect2(16, 16, 16, 16)
				draw_texture_rect_region(GROUND, Rect2(x - 8, y - 8, 16, 16),
						atlas)
