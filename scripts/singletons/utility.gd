extends Node
## A class that holds utility functions.

## Represents the 4 possible axis-aligned directions in a 2D space.
## @deprecated: Just use vectors lol ([constant Vector2.UP], [constant Vector2.RIGHT], [constant Vector2.DOWN], [constant Vector2.LEFT])
enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}


# Cursor :v
var _cursor_normal := AtlasTexture.new()
var _cursor_grabbing := AtlasTexture.new()

func _ready():
	# Frame 0 (normal)
	_cursor_normal.atlas = preload("res://sprites/ui/cursor.png")
	_cursor_normal.region = Rect2(0, 0, 69, 69)

	# Frame 1 (grabbing)
	_cursor_grabbing.atlas = preload("res://sprites/ui/cursor.png")
	_cursor_grabbing.region = Rect2(69, 0, 69, 69)

	Input.set_custom_mouse_cursor(_cursor_normal)


func _process(_delta):
	if Input.is_action_pressed("mb_left"):
		Input.set_custom_mouse_cursor(_cursor_grabbing)
	else:
		Input.set_custom_mouse_cursor(_cursor_normal)

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
	return get_tree().get_first_node_in_group(group_name)


## Shorthand for getting a group of nodes:
## [codeblock]
## # Long syntax:
## get_tree().get_nodes_in_group("ui")
## # Short syntax:
## Utility.group("ui")
## [/codeblock]
func group(group_name: StringName) -> Array[Node]:
	return get_tree().get_nodes_in_group(group_name)


## Merges two arrays together. If an element in [param array2] is in
## [param array1], it is not included. Returns a new shallow-copied array.
func array_merge(array1: Array, array2: Array) -> Array:
	var new_array = array1.duplicate()
	for i in array2:
		if i not in array1:
			new_array.push_back(i)
	return new_array


func _enter_tree():
	Input.set_custom_mouse_cursor(preload("res://sprites/ui/cursor.png"))
