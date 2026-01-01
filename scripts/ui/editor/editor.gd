class_name Editor
extends Control

## The currently held part.
var held_part: Part
## The part that the mouse is currently on.
var hovered_part: Part
## Whether the editor is in erase mode.
var erasing := false
## Whether 
var can_interact := true
# Used for checking if a touch effect has already been spawned.
@warning_ignore("unused_private_class_variable")
var _touch_effect: AnimatedSprite2D
var _mouse_down: bool
var _last_mouse_pos: Vector2i


func _init():
	theme = ThemeDB.get_project_theme()


func _process(_delta: float) -> void:
	_last_mouse_pos = %EditorMap.coords(%EditorMap.get_global_mouse_position())
	var selected = get_selected_part()
	if _can_place():
		if not selected.multi_place:
			return
		if not %EditorMap.is_free(Rect2i(_last_mouse_pos, selected.size)):
			return
		place(_last_mouse_pos)



func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				_mouse_down = event.pressed
				if event.pressed:
					_last_mouse_pos = %EditorMap.coords(
							%EditorMap.get_global_mouse_position())
					var selected = get_selected_part()
					if _can_place() and selected != null:
						if selected.multi_place:
							return
						if %EditorMap.get_tile(_last_mouse_pos) != null:
							return
						place(_last_mouse_pos)
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


func _can_place() -> bool:
	return get_selected_part() != null and _mouse_down and held_part == null \
			and has_focus() and %EditorMap.is_in_bounds(_last_mouse_pos) \
			and not erasing

## Places a tile at [param pos] and returns the placed [Part].
func place(pos: Vector2i) -> Part:
	var part = get_selected_part().part.instantiate()
	%EditorMap.set_tile(pos, part)
	UISoundPlayer.stream = load("uid://2x6kk0s4njjp")
	UISoundPlayer.play()
	return part
