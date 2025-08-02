extends Node
## A class that holds utility functions.

## Represents the 4 possible axis-aligned directions in a 2D space.
enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

# Cursor :v
var cursor_sheet = preload("res://sprites/cursor.png")
var cursor_normal := AtlasTexture.new()
var cursor_grabbing := AtlasTexture.new()

func _ready():
	# Frame 0 (normal)
	cursor_normal.atlas = cursor_sheet
	cursor_normal.region = Rect2(0, 0, 69, 69)

	# Frame 1 (grabbing)
	cursor_grabbing.atlas = cursor_sheet
	cursor_grabbing.region = Rect2(69, 0, 69, 69)

	Input.set_custom_mouse_cursor(cursor_normal)

func set_cursor_frame(frame: int) -> void:
	if frame == 0:
		Input.set_custom_mouse_cursor(cursor_normal)
	elif frame == 1:
		Input.set_custom_mouse_cursor(cursor_grabbing)

func _process(_delta):
	if Input.is_action_pressed("mb_left"):
		set_cursor_frame(1)  # Grabbing
	else:
		set_cursor_frame(0)  # Normal

## Finds a child in the node [param parent] of [param type] type. This function
## only looks at direct children, not descendants.
func find_child_by_class(parent: Node, type: Variant) -> Node:
	for i in parent.get_children():
		if is_instance_of(i, type):
			return i
	return null

## Shorthand for getting the first node from a group:
## [codeblock]
## # Long syntax:
## get_tree().get_first_node_in_group("map")
## # Short syntax:
## Utility.id("map")
## [/codeblock]
func id(group_name: StringName) -> Node:
	print(get_tree().get_first_node_in_group(name))
	return get_tree().get_first_node_in_group(name)

## Merges two arrays together. If an element in [param array2] is in
## [param array1], it is not included. Returns a new shallow-copied array.
func array_merge(array1: Array, array2: Array) -> Array:
	var new_array = array1.duplicate()
	for i in array2:
		if i not in array1:
			new_array.push_back(i)
	return new_array

func _enter_tree():
	get_tree().root.max_size = Vector2i(1153, 648)
	Input.set_custom_mouse_cursor(load("res://sprites/ui/cursor.png"));
