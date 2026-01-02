class_name TileBucket

var tiles: Array[Tile] = []
var rect: Rect2i


func add_tile(tile: Tile) -> void:
	tiles.append(tile)
	rect = rect.merge(tile.rect)


func remove_tile(tile: Tile) -> void:
	if tile in tiles:
		tiles.erase(tile)
		rect.size = Vector2i(0, 0)
		for i in tiles:
			rect = rect.merge(i.rect)
