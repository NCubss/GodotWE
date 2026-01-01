class_name TileComponent
extends Component
## A component that provides easier interactability with maps.

## Fired when this tile connects to a map. This is also fired if the map
## automatically connects this tile.
@warning_ignore("unused_signal")
signal connected
## Fired when this tile disconnects from the given [param map].
@warning_ignore("unused_signal")
signal disconnected(map: Map, pos: Vector2i)

## The map the tile is currently in. This will be always the parent of the 
## tile if it is in a [Map].
@export var map: Map
## The position of the tile in the map.
@export var position: Vector2i = Vector2i.MIN
## The size of the tile in the map.
@export var size: Vector2i = Vector2i(1, 1)


func _ready() -> void:
	# prepare to disconnect in case tile gets freed for some reason
	get_parent().tree_exiting.connect(map_disconnect)


## Disconnects from the map this tile is currently in, if any.
func map_disconnect() -> void:
	if map == null:
		return
	map.disconnect_tile(position)
