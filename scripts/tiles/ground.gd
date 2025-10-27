class_name GroundTile
extends StaticBody2D
## A connecting ground tile.

@onready var tile: TileComponent = $TileComponent
@onready var tex: AtlasTexture = $Sprite.texture

func _ready() -> void:
	_atlas(5, 6)

func _on_tile_connected() -> void:
	# wait for every node to be added to the map, then do the thing
	if not tile.map.is_initialized:
		await tile.map.initialized
	refresh_sprite()

func _on_tile_disconnected(_map: Map, _pos: Vector2i) -> void:
	# reset to single block
	_atlas(5, 6)

func _atlas(x: int, y: int) -> void:
	tex.region.position = Vector2(x, y) * 16

func refresh_sprite() -> void:
	var tp := tile.position
	var top_left = tile.map.get_tile(Vector2i(tp.x - 1, tp.y - 1)) != null
	var top = tile.map.get_tile(Vector2i(tp.x, tp.y - 1)) != null
	var top_right = tile.map.get_tile(Vector2i(tp.x + 1, tp.y - 1)) != null
	var right = tile.map.get_tile(Vector2i(tp.x + 1, tp.y)) != null
	var right_right = tile.map.get_tile(Vector2i(tp.x + 2, tp.y)) != null
	var bottom_right = tile.map.get_tile(Vector2i(tp.x + 1, tp.y + 1)) != null
	var bottom = tile.map.get_tile(Vector2i(tp.x, tp.y + 1)) != null
	var bottom_left = tile.map.get_tile(Vector2i(tp.x - 1, tp.y + 1)) != null
	var left = tile.map.get_tile(Vector2i(tp.x - 1, tp.y)) != null
	var left_left = tile.map.get_tile(Vector2i(tp.x - 2, tp.y)) != null
	
	if tp.y + 1 >= 0:
		bottom_left = true
		bottom = true
		bottom_right = true
	if tp.x - 1 < 0:
		top_left = true
		left = true
		bottom_left = true
	if tp.x - 2 < 0:
		left_left = false
	
	if top:
		if right:
			if top_right:
				if bottom:
					if bottom_right:
						if left:
							if bottom_left:
								if top_left:
									_atlas(randi_range(1, 4), 1)
								else:
									_atlas(2, 9)
							elif top_left:
								_atlas(2, 10)
							else:
								_atlas(2, 8)
						elif right_right:
							_atlas(0, randi_range(1, 4))
						else:
							_atlas(1, 3)
					elif left:
						if bottom_left:
							if top_left:
								_atlas(3, 10)
							else:
								_atlas(4, 4)
						elif top_left:
							_atlas(1, 10)
						else:
							_atlas(4, 2)
					else:
						_atlas(0, 10)
				elif left:
					if top_left:
						_atlas(randi_range(1, 4), 5)
					else:
						_atlas(2, 11)
				elif right_right or bottom_right:
					_atlas(0, 5)
				else:
					_atlas(1, 4)
			elif bottom:
				if bottom_right:
					if left:
						if bottom_left:
							if top_left:
								_atlas(3, 9)
							else:
								_atlas(1, 9)
						elif top_left:
							_atlas(3, 4)
						else:
							_atlas(4, 3)
					else:
						_atlas(0, 9)
				elif left:
					if bottom_left:
						if top_left:
							_atlas(3, 8)
						else:
							_atlas(3, 3)
					elif top_left:
						_atlas(3, 2)
					else:
						_atlas(1, 8)
				else:
					_atlas(0, 8)
			elif left:
				if top_left:
					_atlas(3, 11)
				else:
					_atlas(1, 11)
			else:
				_atlas(0, 11)
		elif bottom:
			if left:
				if bottom_left:
					if top_left:
						if left_left:
							_atlas(5, randi_range(1, 4))
						else:
							_atlas(2, 3)
					else:
						_atlas(4, 9)
				elif top_left:
					_atlas(4, 10)
				else:
					_atlas(4, 8)
			else:
				_atlas(5, 8)
		elif left:
			if top_left:
				if left_left or bottom_left:
					_atlas(5, 5)
				else:
					_atlas(2, 4)
			else:
				_atlas(4, 11)
		else:
			_atlas(5, 9)
	elif right:
		if bottom:
			if bottom_right:
				if left:
					if bottom_left:
						_atlas(randi_range(1, 4), 0)
					else:
						_atlas(2, 7)
				elif right_right or top_right:
					_atlas(0, 0)
				else:
					_atlas(1, 2)
			elif left:
				if bottom_left:
					_atlas(3, 7)
				else:
					_atlas(1, 7)
			else:
				_atlas(0, 7)
		elif left:
			_atlas(randi_range(1, 4), 6)
		else:
			_atlas(0, 6)
	elif bottom:
		if left:
			if bottom_left:
				if left_left or top_left:
					_atlas(5, 0)
				else:
					_atlas(2, 2)
			else:
				_atlas(4, 7)
		else:
			_atlas(5, 7)
	elif left:
		_atlas(5, 6)
	else:
		_atlas(5, 10)
