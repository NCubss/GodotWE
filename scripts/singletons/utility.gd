extends Node
## A class that holds utility functions.

## The primary yellow color in the game.
const COLOR_YELLOW = Color("#facd00")
const COLOR_DARK = Color("#5d1c1c")
## The smallest possible [int] number.
const INT_MIN = Vector2i.MIN.x
## The largest possible [int] number.
const INT_MAX = Vector2i.MAX.x

var camera_position_raw: Vector2:
	get():
		return -get_viewport().canvas_transform.origin
	set(v):
		get_viewport().canvas_transform.origin = -v
var camera_position: Vector2:
	get():
		return -get_viewport().canvas_transform.origin \
				/ get_viewport().canvas_transform.get_scale()
	set(v):
		get_viewport().canvas_transform.origin = -v \
				* get_viewport().canvas_transform.get_scale()
var camera_scale: Vector2:
	get():
		return get_viewport().canvas_transform.get_scale()
	set(v):
		get_viewport().canvas_transform.x = get_viewport().canvas_transform \
				.x.normalized() * v.x
		get_viewport().canvas_transform.y = get_viewport().canvas_transform \
				.y.normalized() * v.y
		
## The player's username. Based on the project setting
## [code]game/user/username[/code].
var username: String:
	get():
		return ProjectSettings.get_setting("game/user/username")
	set(v):
		ProjectSettings.set_setting("game/user/username", v)


func _ready() -> void:
	pass
	#Input.use_accumulated_input = false


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


## Snaps the vector [param x] to a grid with a specified cell [param size] and
## a cell [param offset]. [param x] must be a 2D vector ([Vector2]/[Vector2i]),
## however [param size] and [param offset] must be any number or a 2D vector
## type ([int]/[float]/[Vector2]/[Vector2i]). Returns the same type as
## [param x].
func snap(x: Variant, size: Variant, offset: Variant = Vector2.ZERO) -> Variant:
	assert(x is Vector2 or x is Vector2i,
			"Utility.snap() 'x' argument incorrect type")
	if x is Vector2:
		assert(size is int or size is float or size is Vector2i, 
				"Utility.snap() 'size' argument incorrect type")
		assert(offset is int or offset is float or offset is Vector2i,
				"Utility.snap() 'offset' argument incorrect type")
		if size is int or size is float:
			size = Vector2(size, size)
		elif size is Vector2i:
			size = Vector2(size)
		if offset is int or offset is float:
			offset = Vector2(offset, offset)
		elif offset is Vector2i:
			offset = Vector2(offset)
		return ((x / size).floor() * size) + offset
	elif x is Vector2i:
		assert(size is int or size is float or size is Vector2,
				"Utility.snap() 'size' argument incorrect type")
		assert(offset is int or offset is float or offset is Vector2,
				"Utility.snap() 'offset' argument incorrect type")
		if size is int or size is float:
			size = Vector2i(size, size)
		elif size is Vector2:
			size = Vector2i(size)
		if offset is int or offset is float:
			offset = Vector2i(offset, offset)
		elif offset is Vector2:
			offset = Vector2i(offset)
		return ((x / size) * size) + offset
	return null


func snapf(x: float, size: float, offset := 0.0) -> float:
	return (floorf(x / size) * size) + offset


func snapi(x: int, size: int, offset := 0) -> int:
	@warning_ignore("integer_division")
	return ((x / size) * size) + offset


func snap2(x: Vector2, size: Vector2, offset := Vector2.ZERO) -> Vector2:
	return ((x / size).floor() * size) + offset


func snap2i(x: Vector2i, size: Vector2i, offset := Vector2i.ZERO) -> Vector2i:
	@warning_ignore("integer_division")
	return ((x / size) * size) + offset
