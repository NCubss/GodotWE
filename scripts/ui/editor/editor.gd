class_name Editor
extends Control

## The level this [Editor] is associated with.
@onready var level: Level = Utility.id("level")

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

# Whether the mouse's left button is currently pressed.
var _mouse_down: bool
# The last calculated grid spot the mouse is on.
var _last_mouse_pos: Vector2i


func _ready():
	theme = ThemeDB.get_project_theme()
	


#func _process(_delta: float) -> void:
	#_process_place(true)



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				_mouse_down = event.pressed
				_process_place(false)
			MouseButton.MOUSE_BUTTON_RIGHT:
				erasing = event.pressed


## Returns the currently selected [PartInfo] from the card bar on the top panel.
## If no [PartInfo] is selected, [code]null[/code] is returned.
func get_selected_part() -> PartInfo:
	var card: EditorCard = EditorCard.card_group.get_pressed_button()
	if card == null:
		return null
	else:
		return card.part


func _process_place(multi_place_allowed: bool) -> void:
	_last_mouse_pos = level.get_global_mouse_position()
	var selected = get_selected_part()
	if selected != null and _mouse_down and can_interact and not erasing:
		if selected.multi_place and not multi_place_allowed:
			return
		var query = PhysicsShapeQueryParameters2D.new()
		query.collide_with_areas = true
		query.collide_with_bodies = false
		query.collision_mask = 256
		var shape = RectangleShape2D.new()
		shape.size = selected.size * 16.0
		query.shape = shape
		query.position = _last_mouse_pos + (shape.size / 2)
		if get_world_2d().direct_space_state.intersect_shape(query, 1) \
				.is_empty():
			place((_last_mouse_pos / 16.0).floor())


## Places a tile at [param pos] and returns the placed [Part].
func place(pos: Vector2i) -> Part:
	var part: Part = get_selected_part().part.instantiate()
	level.current_sub_area.editor_foreground.add_child(part)
	part.global_position = pos * 16.0
	UISoundPlayer.stream = load("uid://2x6kk0s4njjp")
	UISoundPlayer.play()
	return part
