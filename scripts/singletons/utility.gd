extends Node
## A class that holds utility functions.

## Represents the 4 possible axis-aligned directions in a 2D space.
enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

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
