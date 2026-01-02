class_name FastMap
extends Node2D
## A reimplementation of the [Map] with optimizations.
## 
## [FastMap]s take less responsibility about their tiles with the benefit of
## more performance. They do not require [TileComponent]s, as the tiles directly
## contact the [FastMap] for updates and changes. A [MapConnector] can be used
## to automatically connect to a [FastMap] when ready.

## Emitted usually once per call when the map experiences a change, such as a
## tile being added or cleared. 
signal changed(rect: Rect2i)

## The size of one grid spot or cell.
@export var cell_size := Vector2(16, 16)


var _buckets: Array[TileBucket] = []


## Gets the tiles intersecting [param rect].
func get_tiles(rect: Rect2i) -> Array[Tile]:
	var buckets = _buckets.filter(func(b: TileBucket): return b.rect.intersects(rect))
	var tiles = []
	for i: TileBucket in buckets:
		tiles.append_array(i.tiles)
	return tiles.filter(func(t: Tile): return rect.intersects(t.rect))


## Sets a tile representing [param node] covering [param rect]. If
## [param allow_overlaps] is [code]true[/code], the map does not clear previous
## tiles in this tile's area prior to assigning it.
func set_tile(node: Node, rect: Rect2i, allow_overlaps := false) -> Tile:
	# if no overlaps:
		# find tiles that overlap
		# delete them
	# find bucket to place tile in
	# create new tile
	var full_rect = rect
	if not allow_overlaps:
		var buckets = _buckets.filter(func(b: TileBucket): return b.rect.intersects(rect))
		for i: TileBucket in buckets:
			i.tiles = i.tiles.filter(func(t: Tile): return not rect.intersects(t.rect))
			
		#for i in get_tiles(rect):
			#tiles.erase(i)
			#var tile_rect = i.rect
			#i.map = null
			#i.bucket = null
			#i.rect = Rect2i()
			#i.removed.emit(self, tile_rect)
			#get_node(i.node_path).queue_free()
			#full_rect = full_rect.merge(i.rect)
	var tile = Tile.new()
	tile.map = self
	tile.rect = rect
	if node.get_parent() == null:
		add_child(node)
	elif node.get_parent() != self:
		node.reparent(self)
	tile.node_path = node.get_path()
	tiles.append(tile)
	_nodes[tile.node_path] = tile
	node.global_position = to_global_coords(rect.position)
	changed.emit(full_rect)
	return tile


## Clears all tiles intersecting [param rect].
func clear_tiles(rect: Rect2i) -> void:
	var full_rect = rect
	for i in get_tiles(rect):
		tiles.erase(i)
		var tile_rect = i.rect
		i.map = null
		i.rect = Rect2i()
		i.removed.emit(self, tile_rect)
		get_node(i.node_path).queue_free()
		full_rect = full_rect.merge(i.rect)
	changed.emit(full_rect)


## Checks if [param rect] is empty on this map.
func is_area_free(rect: Rect2i) -> bool:
	return tiles.all(func(t: Tile): return not rect.intersects(t.rect))


## Converts [param pos] from global coordinates to a matching cell position on
## this map. The opposite of [method to_global_coords].
func to_map_coords(pos: Vector2) -> Vector2i:
	return Vector2i((to_local(pos) / cell_size).floor())


## Returns the global position for the cell position [param pos]. The opposite
## of [method to_map_coords].
func to_global_coords(pos: Vector2i) -> Vector2:
	return to_global(Vector2(pos) * cell_size)
