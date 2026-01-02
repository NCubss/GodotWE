class_name Tile
extends Resource
## Represents a tile on a [FastMap].

## Emitted when [signal FastMap.changed] is emitted.
signal map_changed(rect: Rect2i)
## Emitted when this tile is removed from [member map].
signal removed(map: FastMap, rect: Rect2i)

## The area this tile takes up on the [member map].
@export var rect: Rect2i
## The path to the node this tile represents.
@export var node_path: NodePath

## The [FastMap] this tile is in.
var map: FastMap:
	set(value):
		if map != null:
			map.changed.disconnect(map_changed.emit)
		if value != null:
			value.changed.connect(map_changed.emit)
		map = value
## The map's [TileBucket] this tile is in.
var bucket: TileBucket


## Invalidates this tile and removes it from [member map].
func remove() -> void:
	if map == null:
		return
	var old_map = map
	var old_rect = rect
	map = null
	rect = Rect2i()
	removed.emit(old_map, old_rect)


## Converts [member rect] to one using global coordinates.
func to_global_coords() -> Rect2:
	return Rect2(map.to_global_coords(rect.position),
			Vector2(rect.size) * map.cell_size)
