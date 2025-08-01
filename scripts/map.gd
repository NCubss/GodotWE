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

## The size of a space in the [Map] as a vector.
@export var tile_size = Vector2(16, 16)

## Fires when [member Map.is_initialized] is set to [code]true[/code].
signal initialized

## Fires when a tile has been set, cleared, disconnected, moved, or switched.
## Only fired once for each method call, so [method Map.clear_rect] will only
## fire this signal once, for example. Does not fire with
## [signal Map.initialized].
signal changed

func _ready() -> void:
	for i in get_children():
		var comp = Utility.find_child_by_class(i, TileComponent) as TileComponent
		if comp == null:
			continue
		comp.map = self
		if comp.position == Vector2i(0, 0):
			comp.position = Vector2i(i.position / tile_size)
		tiles[comp.position] = i
		comp.connected.emit()
	is_initialized = true

## Sets a space in the map to the given [param node]. If there already is a tile
## at the given [param pos], it will clear it from the map. If the node is
## [code]null[/code], the tile at the position will not be affected.
func set_tile(pos: Vector2i, node: Node2D) -> void:
	clear_tile(pos)
	if node != null:
		add_child(node)
		tiles[pos] = node
		# update node and component
		var comp = Utility.find_child_by_class(node, TileComponent)
		assert(comp != null, "Tile does not have a TileComponent")
		node.position = Vector2(pos) * tile_size
		comp.map = self
		comp.position = pos
		comp.connected.emit()
		changed.emit()

## Clears a space in the map, disconnecting the node at the position and freeing
## it. To clear a rectangular space of tiles, see [method Map.clear_rect].
func clear_tile(pos: Vector2i) -> void:
	var node = tiles[pos]
	if node == null:
		return
	tiles.erase(pos)
	node.queue_free()
	changed.emit()

## Clears a rectangular space of tiles in the map.
func clear_rect(top_left: Vector2i, bottom_right: Vector2i) -> void:
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			clear_tile(Vector2i(x, y));

## Disconnects a tile from the map. The tile will remain existing as a child of
## the map node, but will not be kept in the [member Map.tiles] dictionary.
## Returns the disconnected node. To additionally free the node, see
## [method Map.clear_tile].
func disconnect_tile(pos: Vector2i) -> Node2D:
	var node = tiles[pos]
	if node == null:
		return null
	tiles.erase(pos)
	var comp = Utility.find_child_by_class(node, TileComponent) as TileComponent
	assert(comp != null, "Tile does not have a TileComponent")
	comp.map = null
	comp.position = Vector2i(0, 0)
	comp.disconnected.emit(self, pos)
	changed.emit()
	return node

## Moves the tile at the given [param old_pos] to the given [param new_pos].
## The tile at [param new_pos] will be cleared if there is one. Will trigger
## [signal TileComponent.disconnected] and [signal TileComponent.connected].
## Returns the moved node.
func move_tile(old_pos: Vector2i, new_pos: Vector2i) -> Node2D:
	var node = disconnect_tile(old_pos)
	if node == null:
		return null
	set_tile(new_pos, node)
	return node

## Switches the tiles at [param pos1] and [param pos2] around. Will trigger
## [signal TileComponent.disconnected] and [signal TileComponent.connected] for
## both tiles.
func switch_tiles(pos1: Vector2i, pos2: Vector2i) -> void:
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
