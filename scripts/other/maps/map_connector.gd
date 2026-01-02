class_name MapConnector
extends Node
## Automatically connects the parent node to its parent [FastMap].
## 
## Once it connects, [signal done] is emitted, giving access to the [Tile] and
## [FastMap]. Regardless of the result, the node will be freed.

## The size of this tile.
@export var size := Vector2i(1, 1)
@export var allow_overlaps := false

## Emitted when the [MapConnector] connects to a map.
signal done(tile: Tile, map: FastMap)


func _ready() -> void:
	await get_parent().ready
	await get_parent().get_parent().ready
	if get_parent().get_parent() is FastMap:
		var map: FastMap = get_parent().get_parent()
		done.emit(map.set_tile(get_parent(),
				Rect2i(map.to_map_coords(get_parent().global_position), size)),
				map)
	queue_free()
