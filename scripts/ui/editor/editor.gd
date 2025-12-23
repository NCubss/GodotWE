class_name Editor
extends Control

## The currently held part.
var held_part: Part
## The part that the mouse is currently on.
var hovered_part: Part
## Whether the editor is in erase mode.
var erasing: bool
# Used for checking if a touch effect has already been spawned.
@warning_ignore("unused_private_class_variable")
var _touch_effect: AnimatedSprite2D
var _mouse_down: bool
var _last_mouse_pos: Vector2i


func _init():
	theme = ThemeDB.get_project_theme()


func _process(_delta: float) -> void:
	_last_mouse_pos = Utility.id("editor_map") \
			.coords(Utility.id("editor_map").get_global_mouse_position())
	var selected = get_selected_part()
	if selected != null and _mouse_down and held_part == null and has_focus() and not erasing:
		var map: Map = Utility.id("editor_map")
		var tile = map.get_tile(_last_mouse_pos)
		if tile == null:
			var part = selected.part.instantiate()
			var tile_comp = Utility.find_child_by_class(part, TileComponent)
			var play_sound = true
			if tile_comp != null:
				map.set_tile(_last_mouse_pos, part)
			elif hovered_part == null:
				map.add_child(part)
				hovered_part = part
				part.global_position = Vector2(_last_mouse_pos) * map.tile_size
			else:
				play_sound = false
			if play_sound:
				UISoundPlayer.stream = load("uid://2x6kk0s4njjp")
				UISoundPlayer.play()
	print(hovered_part)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MouseButton.MOUSE_BUTTON_LEFT:
				_mouse_down = event.pressed
			MouseButton.MOUSE_BUTTON_RIGHT:
				erasing = event.pressed


## Returns the currently selected [PartInfo] from the card bar on the top panel.
## If no [PartInfo] is selected, [code]null[/code] is returned.
func get_selected_part() -> PartInfo:
	var card = EditorCard.card_group.get_pressed_button() as EditorCard
	if card == null:
		return null
	else:
		return card.part
