class_name Tile
extends Resource
## Represents a tile on a [FastMap].


## The area this tile takes up on the [member Tile.map].
@export var rect: Rect2i
## The path to the node this tile represents.
@export var node_path: NodePath

## The [FastMap] this tile is in.
var map: FastMap


## Invalidates this tile and removes it from [member map].
func remove() -> void:
	if map != null:
		map.tiles.erase(self)
	map = null
	rect = Rect2i()
	node_path = ^""


## Converts [member rect] to one using global coordinates.
func to_global_coords() -> Rect2:
	return Rect2(map.to_global_coords(rect.position),
			Vector2(rect.size) * map.cell_size)
