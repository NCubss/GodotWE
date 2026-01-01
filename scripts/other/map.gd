class_name Map
extends Node2D
## A custom tile map implementation designed with scenes in mind.
##
## The map node provides a simple tile map system, with child nodes being
## tiles. Every node contained in a map node must have the [TileComponent] for
## interacting with the map.
## [br][br]
## When the map enters the scene tree, it will automatically check its children
## and connect them to the map, as long as they have a [TileComponent].

## The size of a space in the [Map] as a vector.
@export var tile_size = Vector2(16, 16)

@export_group("Limits")
## The left limit on the x axis. Limits are not inclusive, so you cannot place
## tiles on a limit.
@export var limit_left := Utility.INT_MIN
## The top limit on the y axis. Limits are not inclusive, so you cannot place
## tiles on a limit.
@export var limit_top := Utility.INT_MIN
## The right limit on the x axis. Limits are not inclusive, so you cannot place
## tiles on a limit.
@export var limit_right := Utility.INT_MAX
## The bottom limit on the y axis. Limits are not inclusive, so you cannot place
## tiles on a limit.
@export var limit_bottom := Utility.INT_MAX

## A dictionary keeping track of all nodes in the map. This property shouldn't
## be directly modified outside of this class; it's safer to to use the map's
## methods, as they additionally handle [TileComponent]s.
var tiles: Dictionary[Vector2i, Node2D] = {}
## Whether all child nodes, which have entered the scene tree together with the
## map, have been registered into [member Map.tiles].
var is_initialized := false:
	set(value):
		is_initialized = value
		if value:
			initialized.emit()

## Fires when [member Map.is_initialized] is set to [code]true[/code].
signal initialized
## Fires when a tile has been set, cleared, disconnected, moved, or switched.
## Only fired once for each method call, so [method Map.clear_rect] will only
## fire this signal once, for example. Does not fire with
## [signal Map.initialized].
signal changed


func _ready() -> void:
	# find tiles and connect them
	for i: Node in get_children():
		if i is not Node2D:
			push_warning("Nodes which are not Node2D are unsupported with Maps")
			continue
		var comp: TileComponent = Utility.find_child_by_class(i, TileComponent)
		if comp == null:
			push_warning("Child of Map does not have TileComponent")
			continue
		if comp.position == Vector2i.MIN:
			comp.position = coords(i.global_position)
			if not is_in_bounds(comp.position):
				push_warning("Tile is outside of this Map's bounds")
				continue
		clear_rect(Rect2i(comp.position, comp.size))
		for x in range(comp.position.x, comp.position.x + comp.size.x):
			for y in range(comp.position.y, comp.position.y + comp.size.y):
				tiles[Vector2i(x, y)] = i
		comp.map = self
		comp.connected.emit()
	is_initialized = true


## Sets a space in the map to the given [param node]. If there already is a tile
## at the given [param pos], it will clear it from the map. If the node is
## [code]null[/code], the tile at the position will not be affected.
func set_tile(pos: Vector2i, node: Node2D) -> void:
	assert(is_in_bounds(pos), "Position is outside of this Map's bounds")
	var comp: TileComponent = Utility.find_child_by_class(node, TileComponent)
	# force TileComponent
	assert(comp != null, "Tile does not have a TileComponent")
	# make node child of map
	if node.get_parent() == null:
		add_child(node)
	else:
		node.reparent(self)
	# check if tile is already on the map
	if comp.map == self:
		for x in range(comp.position.x, comp.position.x + comp.size.x):
			for y in range(comp.position.y, comp.position.y + comp.size.y):
				tiles.erase(Vector2i(x, y))
	# update node and component
	node.position = Vector2(pos) * tile_size
	comp.map = self
	comp.position = pos
	clear_rect(Rect2i(comp.position, comp.size))
	for x in range(comp.position.x, comp.position.x + comp.size.x):
		for y in range(comp.position.y, comp.position.y + comp.size.y):
			tiles[Vector2i(x, y)] = node
	comp.connected.emit()
	# prevent null tiles
	if not node.tree_exiting.is_connected(_tile_exited.bind(comp, comp.position)):
		node.tree_exiting.connect(_tile_exited.bind(comp, comp.position),
				ConnectFlags.CONNECT_ONE_SHOT)
	changed.emit(pos)


## Clears a space in the map, disconnecting the node at the position and freeing
## it. To clear a rectangular space of tiles, see [method Map.clear_rect].
func clear_tile(pos: Vector2i) -> void:
	assert(is_in_bounds(pos), "Position is outside of this Map's bounds")
	# do nothing if it is already empty
	if not tiles.has(pos):
		return
	# find and erase
	var node = tiles[pos]
	#var comp: TileComponent = Utility.find_child_by_class(node, TileComponent)
	#assert(comp != null, "Tile does not have a TileComponent")
	#for x in range(comp.position.x, comp.position.x + comp.size.x):
		#for y in range(comp.position.y, comp.position.y + comp.size.y):
			#tiles.erase(Vector2i(x, y))
	node.queue_free()


## Clears a rectangular space of tiles in the map.
func clear_rect(rect: Rect2i) -> void:
	assert(is_in_bounds(rect.position) and is_in_bounds(rect.end),
			"Rectangle is outside of this Map's bounds")
	for x in range(rect.position.x, rect.end.x + 1):
		for y in range(rect.position.y, rect.end.y + 1):
			clear_tile(Vector2i(x, y))


## Disconnects a tile from the map. The tile will remain existing as a child of
## the map node, but will not be kept in the [member Map.tiles] dictionary.
## Returns the disconnected node. To additionally free the node, see
## [method Map.clear_tile].
func disconnect_tile(pos: Vector2i) -> Node2D:
	assert(is_in_bounds(pos), "Position is outside of this Map's bounds")
	# do nothing if it is already empty
	if not tiles.has(pos):
		return null
	var node = tiles[pos]
	var comp: TileComponent = Utility.find_child_by_class(node, TileComponent)
	assert(comp != null, "Tile does not have a TileComponent")
	for x in range(comp.position.x, comp.position.x + comp.size.x):
		for y in range(comp.position.y, comp.position.y + comp.size.y):
			tiles.erase(Vector2i(x, y))
	if node.tree_exiting.is_connected(_tile_exited.bind(comp, comp.position)):
		node.tree_exiting.disconnect(_tile_exited.bind(comp, comp.position))
	comp.map = null
	comp.position = Vector2i.MIN
	comp.disconnected.emit(self, pos)
	changed.emit(pos)
	return node


## Moves the tile at the given [param current_pos] to the given [param new_pos].
## The tile at [param new_pos] will be cleared if there is one. Attempting to
## move an empty tile will clear the tile at [param new_pos]. Will trigger
## [signal TileComponent.disconnected] and [signal TileComponent.connected].
## Returns the moved node.
func move_tile(current_pos: Vector2i, new_pos: Vector2i) -> Node2D:
	assert(is_in_bounds(current_pos) and is_in_bounds(new_pos),
			"Position is outside of this Map's bounds")
	var node = disconnect_tile(current_pos)
	set_tile(new_pos, node)
	return node
	#var emit_current = false
	#var emit_new = false
	#if tiles[new_pos] != null:
		#tiles[new_pos].queue_free()
		#tiles.erase(new_pos)
		#emit_new = true
	#var node = tiles[current_pos]
	#if node != null:
		#tiles.erase(current_pos)
		#var comp: TileComponent = Utility.find_child_by_class(
				#node, TileComponent)
		#assert(comp != null, "Tile does not have a TileComponent")
		#comp.map = null
		#comp.position = Vector2i(0, 0)
		#comp.disconnected.emit(self, current_pos)
		#emit_current = true
		#tiles[new_pos] = node
		#comp.map = self
		#comp.position = new_pos
		#comp.connected.emit()
		#emit_new = true
	#if emit_current:
		#changed.emit(current_pos)
	#if emit_new:
		#changed.emit(new_pos)
	#return node


## Switches the tiles at [param pos1] and [param pos2] around. Will trigger
## [signal TileComponent.disconnected] and [signal TileComponent.connected] for
## both tiles.
func switch_tiles(pos1: Vector2i, pos2: Vector2i) -> void:
	assert(is_in_bounds(pos1) and is_in_bounds(pos2),
			"Position is outside of this Map's bounds")
	var node1 = disconnect_tile(pos1)
	var node2 = disconnect_tile(pos2)
	set_tile(pos1, node2)
	set_tile(pos2, node1)


## Returns the tile at the given [param pos]. Returns [code]null[/code] if there
## is not a tile at the position.
func get_tile(pos: Vector2i) -> Node2D:
	if tiles.has(pos):
		return tiles[pos]
	else:
		return null


## Converts the [param pos] from global coordinates to this [Map]'s tile
## coordinates.
func coords(pos: Vector2) -> Vector2i:
	return Vector2i((to_local(pos) / tile_size).floor())


## Checks if the specified [param pos] is within the limits of this [Map].
func is_in_bounds(pos: Vector2i) -> bool:
	return pos.x > limit_left \
			and pos.x < limit_right \
			and pos.y > limit_top \
			and pos.y < limit_bottom


## Checks if the specified [param rect] is empty. Returns [code]false[/code] if
## the rectangle is not within the limits of this [Map].
func is_free(rect: Rect2i) -> bool:
	if rect.position.x <= limit_left \
			or rect.end.x >= limit_right \
			or rect.position.y <= limit_top \
			or rect.end.y >= limit_bottom:
		return false
	var result := true
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if tiles.has(Vector2i(x, y)):
				result = false
	return result


func _tile_exited(comp: TileComponent, pos: Vector2i) -> void:
	if comp.map != null:
		for x in range(comp.position.x, comp.position.x + comp.size.x):
			for y in range(comp.position.y, comp.position.y + comp.size.y):
				tiles.erase(Vector2i(x, y))
		comp.map = null
		comp.position = Vector2i.MIN
		comp.disconnected.emit(self, pos)
