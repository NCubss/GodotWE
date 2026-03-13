class_name Editor
extends Control

## The level this [Editor] is associated with.
var level: Level:
	set(v):
		level = v
		v.add_child(grid)
		v.playing.connect(_play)
		v.editing.connect(_edit)
## The currently held part.
var held_part: Part
## The part that the mouse is currently on.
var hovered_part: Part
## Whether the editor is in erase mode.
var erasing := false
## Whether the user can currently interact with tiles and panel buttons. This
## is typically set by held parts and popouts to disable the rest of the UI.
var can_interact := true
## The currently displayed touch effect. Used to limit one at a time.
var touch_effect: AnimatedSprite2D
var grid := Grid.new()

# Whether the mouse's left button is currently pressed.
var _mouse_down: bool
# The last calculated grid spot the mouse is on.
var _last_mouse_pos: Vector2i


func _ready():
	grid.minor_color = Color("00000099")
	grid.major_color = Color("000000ff")
	grid.modulate = Color("ffffff40")
	theme = ThemeDB.get_project_theme()
	MusicPlayer.stream = preload("uid://dq3thvj6cinc0")
	MusicPlayer.play()


func _process(_delta: float) -> void:
	_process_place(true)



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				_mouse_down = event.pressed
				_process_place(false)
			MouseButton.MOUSE_BUTTON_RIGHT:
				erasing = event.pressed


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == Key.KEY_H and event.pressed:
			if level.status == Level.Status.EDITING:
				level.play()
			elif level.status == Level.Status.PLAYING:
				level.edit()


## Returns the currently selected [PartInfo] from the card bar on the top panel.
## If no [PartInfo] is selected, [code]null[/code] is returned.
func get_selected_part() -> PartInfo:
	var card: EditorCard = preload("uid://dhdt3ovnv8ci2").get_pressed_button()
	if card == null:
		return null
	else:
		return card.part


func _process_place(multi_place_allowed: bool) -> void:
	_last_mouse_pos = level.get_global_mouse_position()
	var selected = get_selected_part()
	if selected == null or not _mouse_down:
		return
	if not can_interact or erasing:
		return
	if selected.multi_place and not multi_place_allowed:
		return
	if held_part != null:
		return
	var query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 1 << 8
	var shape = RectangleShape2D.new()
	shape.size = level.from_grid(selected.size) - Vector2(2, 2)
	query.shape = shape
	query.transform.origin = level.snap(_last_mouse_pos) + \
			(level.from_grid(selected.size) / 2.0)
	if get_world_2d().direct_space_state.intersect_shape(query, 1) \
			.is_empty():
		place(level.to_grid(_last_mouse_pos))


## Places a tile at [param pos] and returns the placed [Part].
func place(pos: Vector2i) -> Part:
	var part: Part = get_selected_part().part.instantiate()
	level.current_sub_area.add_part(part)
	part.global_position = level.from_grid(pos)
	UISoundPlayer.stream = load("uid://2x6kk0s4njjp")
	UISoundPlayer.play()
	return part


func _play() -> void:
	hide()
	%TopPanel.extended = false
	%TopPanel.locked = true
	%LeftPanel.extended = false
	%LeftPanel.locked = true
	%RightPanel.extended = false
	%RightPanel.locked = true
	grid.hide()


func _edit() -> void:
	show()
	%TopPanel.locked = false
	%TopPanel.extended = true
	%LeftPanel.locked = false
	%LeftPanel.extended = true
	%RightPanel.locked = false
	%RightPanel.extended = true
	grid.show()
	MusicPlayer.stream = preload("uid://dq3thvj6cinc0")
	MusicPlayer.play()
