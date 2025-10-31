class_name GroundTile
extends StaticBody2D
## A connecting ground tile.

@onready var tile := $TileComponent as TileComponent
@onready var tex := $Sprite.texture as AtlasTexture

func _ready() -> void:
	atlas(64, 32)

func _on_tile_connected() -> void:
	# wait for every node to be added to the map, then do the thing
	if not tile.map.is_initialized:
		await tile.map.initialized
	refresh_sprite()

func _on_tile_disconnected(_map: Map, _pos: Vector2i) -> void:
	# reset to single block
	atlas(64, 32)

func atlas(x: float, y: float) -> void:
	tex.region.position = Vector2(x, y)

func choose() -> float:
	return abs(fmod((tile.position.x + tile.position.y), 4)) * 16

func refresh_sprite() -> void:
	var tp := tile.position
	var top_left = tile.map.get_tile(Vector2i(tp.x - 1, tp.y - 1)) != null
	var top = tile.map.get_tile(Vector2i(tp.x, tp.y - 1)) != null
	var top_right = tile.map.get_tile(Vector2i(tp.x + 1, tp.y - 1)) != null
	var right = tile.map.get_tile(Vector2i(tp.x + 1, tp.y)) != null
	var bottom_right = tile.map.get_tile(Vector2i(tp.x + 1, tp.y + 1)) != null
	var bottom = tile.map.get_tile(Vector2i(tp.x, tp.y + 1)) != null
	var bottom_left = tile.map.get_tile(Vector2i(tp.x - 1, tp.y + 1)) != null
	var left = tile.map.get_tile(Vector2i(tp.x - 1, tp.y)) != null
	
	if tp.y + 1 >= 0:
		bottom_left = true
		bottom = true
		bottom_right = true
	if tp.x - 1 < 0:
		top_left = true
		left = true
		bottom_left = true
	
	if not top and right and bottom_right and bottom and not left:
		atlas(0, 0)
	if not top and right and bottom_right and bottom and bottom_left and left:
		atlas(16 + choose(), 0)
	if not top and not right and bottom and bottom_left and left:
		atlas(80, 0)
	if not top and right and not bottom_right and bottom and not left:
		atlas(96, 0)
	if not top and right and not bottom_right and bottom and not bottom_left and left:
		atlas(112, 0)
	if not top and right and bottom_right and bottom and not bottom_left and left:
		atlas(128, 0)
	if not top and right and not bottom_right and bottom and bottom_left and left:
		atlas(144, 0)
	if not top and not right and bottom and not bottom_left and left:
		atlas(160, 0)
	if top and top_right and right and bottom_right and bottom and not left:
		atlas(0, 16 + (randi() % 4) * 16)
	if top and top_right and right and bottom_right and bottom and bottom_left and left and top_left:
		atlas(16 + (randi() % 4) * 16, 16)
	if top and not right and bottom and bottom_left and left and top_left:
		atlas(80, 16 + (randi() % 4) * 16)
	if top and not top_right and right and not bottom_right and bottom and not left:
		atlas(96, 16)
	if top and not top_right and right and not bottom_right and bottom and not bottom_left and left and not top_left:
		atlas(112, 16)
	if top and top_right and right and bottom_right and bottom and not bottom_left and left and not top_left:
		atlas(128, 16)
	if top and not top_right and right and not bottom_right and bottom and bottom_left and left and top_left:
		atlas(144, 16)
	if top and not right and bottom and not bottom_left and left and not bottom_left:
		atlas(160, 16)
	if not top and not right and bottom and not left:
		atlas(16, 32)
	if top and not top_right and right and not bottom_right and bottom and not bottom_left and left and top_left:
		atlas(32, 32)
	if top and top_right and right and not bottom_right and bottom and not bottom_left and left and not top_left:
		atlas(48, 32)
	if not top and not right and not bottom and not left:
		atlas(64, 32)
	if top and not top_right and right and bottom_right and bottom and not left:
		atlas(96, 32)
	if top and not top_right and right and bottom_right and bottom and bottom_left and left and not top_left:
		atlas(112, 32)
	if top and top_right and right and bottom_right and bottom and bottom_left and left and not top_left:
		atlas(128, 32)
	if top and not top_right and right and bottom_right and bottom and bottom_left and left and top_left:
		atlas(144, 32)
	if top and not right and bottom and bottom_left and left and not top_left:
		atlas(160, 32)
	if top and not right and bottom and not left:
		atlas(16, 48)
	if top and not top_right and right and not bottom_right and bottom and bottom_left and left and not top_left:
		atlas(32, 48)
	if top and not top_right and right and bottom_right and bottom and not bottom_left and left and not top_left:
		atlas(48, 48)
	if top and top_right and right and not bottom_right and bottom and not left:
		atlas(96, 48)
	if top and top_right and right and not bottom_right and bottom and not bottom_left and left and top_left:
		atlas(112, 48)
	if top and top_right and right and bottom_right and bottom and not bottom_left and left and top_left:
		atlas(128, 48)
	if top and top_right and right and not bottom_right and bottom and bottom_left and left and top_left:
		atlas(144, 48)
	if top and not right and bottom and not bottom_left and left and top_left:
		atlas(160, 48)
	if top and not right and not bottom and not left:
		atlas(16, 64)
	if top and not top_right and right and bottom_right and bottom and not bottom_left and left and top_left:
		atlas(32, 64)
	if top and top_right and right and not bottom_right and bottom and bottom_left and left and not top_left:
		atlas(48, 64)
	if not top and right and not bottom and not left:
		atlas(64, 64)
	if top and not top_right and right and not bottom and not left:
		atlas(96, 64)
	if top and not top_right and right and not bottom and left and top_left:
		atlas(112, 64)
	if top and top_right and right and not bottom and left and top_left:
		atlas(128, 64)
	if top and not top_right and right and not bottom and left and top_left:
		atlas(144, 64)
	if top and not right and not bottom and left and not top_left:
		atlas(160, 64)
	if top and top_right and right and not bottom and not left:
		atlas(0, 80)
	if top and top_right and right and not bottom and left and top_left:
		atlas(16 + (randi() % 4) * 16, 80)
	if top and not right and not bottom and left and top_left:
		atlas(80, 80)
	if not top and right and not bottom and left:
		atlas(96 + (randi() % 4) * 16, 80)
	if not top and not right and not bottom and left:
		atlas(160, 80)
