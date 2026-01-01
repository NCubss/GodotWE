class_name GroundPart
extends Part

@onready var _tex: Texture2D = %Sprite.texture
@onready var _tile: TileComponent = Utility.find_child_by_class(self,
		TileComponent)


func _enter_tree() -> void:
	if not is_node_ready():
		await ready
	await _tile.connected
	refresh_sprite()
	_tile.map.changed.connect(_changed)
	_tile.connected.connect(_connected)
	_tile.disconnected.connect(_disconnected)


func _exit_tree() -> void:
	refresh_sprite()


func _connected() -> void:
	refresh_sprite()
	_tile.map.changed.connect(_changed)


func _disconnected(map: Map, _pos: Vector2i) -> void:
	refresh_sprite()
	map.changed.disconnect(_changed)


func _changed(coords: Vector2i) -> void:
	var tp = _tile.position
	if coords.x <= tp.x + 4 and coords.x >= tp.x - 4 and coords.y <= tp.y + 2 and coords.y >= tp.y - 2:
		refresh_sprite()


func _atlas(x: int, y: int) -> void:
	_tex.region.position = Vector2(x, y) * 16


func refresh_sprite() -> void:
	if _tile.map == null:
		_atlas(5, 10)
		return
	
	var tp := _tile.position
	var top_left = _tile.map.get_tile(Vector2i(tp.x - 2, tp.y - 2)) \
			is GroundPart
	var top = _tile.map.get_tile(Vector2i(tp.x, tp.y - 2)) \
			is GroundPart
	var top_right = _tile.map.get_tile(Vector2i(tp.x + 2, tp.y - 2)) \
			is GroundPart
	var right = _tile.map.get_tile(Vector2i(tp.x + 2, tp.y)) \
			is GroundPart
	var right_right = _tile.map.get_tile(Vector2i(tp.x + 4, tp.y)) \
			is GroundPart
	var bottom_right = _tile.map.get_tile(Vector2i(tp.x + 2, tp.y + 2)) \
			is GroundPart
	var bottom = _tile.map.get_tile(Vector2i(tp.x, tp.y + 2)) \
			is GroundPart
	var bottom_left = _tile.map.get_tile(Vector2i(tp.x - 2, tp.y + 2)) \
			is GroundPart
	var left = _tile.map.get_tile(Vector2i(tp.x - 2, tp.y)) \
			is GroundPart
	var left_left = _tile.map.get_tile(Vector2i(tp.x - 4, tp.y)) \
			is GroundPart
	
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
