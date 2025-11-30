extends Node
## A class that holds utility functions.

## The primary yellow color in the game.
const COLOR_YELLOW = Color("#facd00")
const COLOR_DARK = Color("#5d1c1c")



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


## Equivalent to [method Node.add_sibling], except that it adds the
## [param sibling] above the [param node] in the tree.
func add_sibling_up(node: Node, sibling: Node) -> void:
	node.add_sibling(sibling)
	node.get_parent().move_child(sibling, node.get_index() - 1)


## Returns a [Rect2] representing the currently visible screen space. Supports
## viewport skew and rotation.
func get_visible_rect() -> Rect2:
	return (
			get_viewport().canvas_transform.affine_inverse()
			* get_viewport().get_visible_rect()
	)


## Returns an array with the given range.
## This function returns an [Array] of [float]s unlike [method @GDScript.range]
## and works identically.
func rangef(...args: Array) -> Array[float]:
	# invalid argument count
	assert(args.size() <= 3 and args.size() >= 1,
			"Utility.rangef() may have 1-3 arguments.")
	var min_value = 0.0 if args.size() == 1 else args[0]
	var max_value = args[0] if args.size() == 1 else args[1]
	# return empty array if condition is impossible
	if min_value > max_value:
		return []
	var step_value = args[2] if args.size() == 3 else 1.0
	var arr: Array[float] = [min_value]
	while arr[-1] + step_value < max_value:
		arr.append(arr[-1] + step_value)
	return arr
