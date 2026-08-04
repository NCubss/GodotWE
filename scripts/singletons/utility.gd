@icon("uid://6rga5nmncirq")
extends Node
## Singleton that holds utility methods, constants and properties.

## The primary yellow color in the game, [code]#facd00[/code] in hex. When
## designing textures, it's best to use this for consistency.
const COLOR_YELLOW = Color("#facd00")
## The secondary dark brown color in the game, [code]#5d1c1c[/code] in hex.
## When designing textures, it's best to use this for consistency.
const COLOR_DARK = Color("#5d1c1c")

## The position of the top-left corner of the visible view, in screen pixel
## units (i.e. independent of [member camera_scale]). In most scenarios you
## should prefer [member camera_position]. This is a convenience setter/getter
## for [member Viewport.canvas_transform].
var camera_position_raw: Vector2:
	get = _get_camera_position_raw,
	set = _set_camera_position_raw
## The position of the top-left corner of the visible view in viewport
## coordinates. This is a convenience setter/getter for [member
## Viewport.canvas_transform].
var camera_position: Vector2:
	get = _get_camera_position,
	set = _set_camera_position
## The scale of the viewport's canvas transform. This is a convenience
## setter/getter for [member Viewport.canvas_transform].
var camera_scale: Vector2:
	get = _get_camera_scale,
	set = _set_camera_scale

## The player's username. Based on the project setting
## [code]game/user/username[/code].
var username: String:
	get():
		return ProjectSettings.get_setting("game/user/username")
	set(v):
		ProjectSettings.set_setting("game/user/username", v)


## Finds a child in the node [param parent] of [param type] type. This function
## only looks at direct children, not descendants.
func find_child_by_class(parent: Node, type: Variant) -> Node:
	for i in parent.get_children():
		if is_instance_of(i, type):
			return i
	return null


## Equivalent to [method Node.add_sibling], except that it adds the
## [param sibling] above the [param node] in the tree.
func add_sibling_up(node: Node, sibling: Node) -> void:
	node.add_sibling(sibling)
	node.get_parent().move_child(sibling, node.get_index() - 1)


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


## Merges [param array2] into [param array1], excluding items from [param
## array2] that are already in [param array1]. Returns [param array1].
func array_merge(array1: Array, array2: Array) -> Array:
	for i in array2:
		if i not in array1:
			array1.push_back(i)
	return array1


## Returns a [Utility.Rangef] iterator with the given range. Works identically
## to [method @GDScript.range], with an exception for it returning an iterator
## instead for performance.
func rangef(...args: Array) -> Rangef:
	assert(args.size() <= 3 and args.size() >= 1,
			"Utility.rangef() may have 1-3 arguments.")

	var iter = Rangef.new()
	iter.from = 0.0 if args.size() == 1 else float(args[0])
	iter.to = float(args[0]) if args.size() == 1 else float(args[1])
	iter.step = float(args[2]) if args.size() == 3 else 1.0
	return iter


## Returns [method Viewport.get_visible_rect] in [Viewport] coordinates.
func get_visible_rect() -> Rect2:
	return (
			get_viewport().canvas_transform.affine_inverse()
			* get_viewport().get_visible_rect())


## Returns a [Rect2] covering [param obj]'s collision shapes in [Viewport]
## coordinates.
func get_bounding_box(obj: CollisionObject2D) -> Rect2:
	var rect = Rect2()
	for own in obj.get_shape_owners():
		for idx in obj.shape_owner_get_shape_count(own):
			var transform = obj.shape_owner_get_transform(own)
			var shape_rect = obj.shape_owner_get_shape(own, idx).get_rect()
			rect = rect.merge(transform * shape_rect)
	return obj.global_transform * rect


func _get_camera_position_raw() -> Vector2:
	return -get_viewport().canvas_transform.origin


func _set_camera_position_raw(v: Vector2) -> void:
	get_viewport().canvas_transform.origin = -v


func _get_camera_position() -> Vector2:
	return -get_viewport().canvas_transform.origin \
			/ get_viewport().canvas_transform.get_scale()


func _set_camera_position(v: Vector2) -> void:
	get_viewport().canvas_transform.origin = -v \
			* get_viewport().canvas_transform.get_scale()


func _get_camera_scale() -> Vector2:
	return get_viewport().canvas_transform.get_scale()


func _set_camera_scale(v: Vector2) -> void:
	get_viewport().canvas_transform.x = get_viewport().canvas_transform \
			.x.normalized() * v.x
	get_viewport().canvas_transform.y = get_viewport().canvas_transform \
			.y.normalized() * v.y


## Iterates over a [float] range.
##
## You can create a [Utility.Rangef] in two ways:
## [br][br]
## 1. with [method Utility.rangef] (this is the preferred method):
## [codeblock]
## for i in Utility.rangef(10, 5, 100):
##    print(i)
## [/codeblock]
## 2. directly with [method new]:
## [codeblock]
## var rangef = Utility.Rangef.new()
## rangef.from = 10
## rangef.step = 5
## rangef.to = 100
## for i in rangef:
##     print(i)
## [/codeblock]
class Rangef:
	## Starting point. The first iteration will be this value.
	var from := 0.0
	## Ending point. The last iteration will be [b]before[/b] this value. Must
	## not be below or equal to [member from].
	var to: float
	## Step value. Must not be zero.
	var step := 1.0


	func _iter_init(iter: Array) -> bool:
		assert(from < to, "Invalid range given to Rangef")
		assert(step != 0, "Step is 0, Rangef will iterate infinitely")
		iter[0] = from
		return true


	func _iter_next(iter: Array) -> bool:
		iter[0] += step
		return iter[0] < to


	func _iter_get(iter: Variant) -> float:
		return iter
