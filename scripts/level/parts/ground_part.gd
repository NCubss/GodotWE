class_name GroundPart
extends Part

@onready var _tex: Texture2D = %Sprite.texture


func load(placed_from_editor := false) -> void:
	super(placed_from_editor)
	refresh_sprite(placed_from_editor)


func _atlas(x: int, y: int) -> void:
	_tex.region.position = Vector2(x, y) * 16


#func _check(x: int, y: int, refresh := false,
		#override: Dictionary[Vector2i, bool] = {}) -> bool:
	#var absolute_pos = _grid_pos + Vector2i(x, y)
	#if absolute_pos in override:
		#return override[absolute_pos]
	#var query = PhysicsPointQueryParameters2D.new()
	#query.collide_with_areas = true
	#query.collide_with_bodies = false
	#query.collision_mask = 1 << 8
	#query.exclude = [get_rid()]
	#query.position = level.from_grid(_grid_pos + Vector2i(x, y)) + level.GRID_SIZE / 2
	#var result = get_world_2d().direct_space_state.intersect_point(query, 1)
	#if not result.is_empty() and result[0]["collider"] is GroundPart:
		#if refresh:
			#result[0]["collider"].refresh_sprite()
		#return true
	#else:
		#return false


func _hold() -> void:
	super()
	reset_sprite()
	_notify_tiles(_get_nearby_tiles(_original_pos))


func _unhold() -> void:
	super()
	# this must be deferred due to collision layer possibly not updating fast
	# enough
	var deferred = func():
		var tiles = _get_nearby_tiles(_grid_pos)
		_notify_tiles(tiles)
		_connect(_grid_pos, tiles)
	deferred.call_deferred()


func erase(silent := false) -> void:
	super(silent)
	var tiles = _get_nearby_tiles(_grid_pos)
	get_parent().remove_child(self)
	_notify_tiles(tiles)


func build() -> void:
	var tile = preload("uid://bpy1sebdq7k7s").instantiate()
	tile.global_position = global_position
	tile.get_node(^"%Sprite").texture = %Sprite.texture
	sub_area.add(tile)


func refresh_sprite(refresh_nearby := true) -> void:
	if held:
		reset_sprite()
		if refresh_nearby:
			var tiles = _get_nearby_tiles(_original_pos)
			_notify_tiles(tiles)
	else:
		var tiles = _get_nearby_tiles(_grid_pos)
		if refresh_nearby:
			_notify_tiles(tiles)
		_connect(_grid_pos, tiles)


func reset_sprite() -> void:
	_atlas(5, 10)


func _get_nearby_tiles(
		pos: Vector2i,
		base: Dictionary[Vector2i, GroundPart] = {}
) -> Dictionary[Vector2i, GroundPart]:
	for x in range(-2, 3):
		for y in range(-1, 2):
			if Vector2i(x, y) in base:
				continue
			var query = PhysicsPointQueryParameters2D.new()
			query.collide_with_areas = true
			query.collide_with_bodies = false
			query.collision_mask = 1 << 8
			query.exclude = [get_rid()]
			query.position = level.from_grid(pos + Vector2i(x, y)) \
					+ level.GRID_SIZE / 2
			var result = get_world_2d().direct_space_state \
					.intersect_point(query, 1)
			if not result.is_empty():
				base[Vector2i(x, y)] = result[0]["collider"] as GroundPart
			else:
				base[Vector2i(x, y)] = null
	return base


func _notify_tiles(tiles: Dictionary[Vector2i, GroundPart]) -> void:
	for i: GroundPart in tiles.values():
		if i != null:
			i.refresh_sprite(false)


func _connect(pos: Vector2i, data: Dictionary[Vector2i, GroundPart]) -> void:
	var top_left = data[Vector2i(-1, -1)] != null
	var top = data[Vector2i(0, -1)] != null
	var top_right = data[Vector2i(1, -1)] != null
	var right = data[Vector2i(1, 0)] != null
	var right_right = data[Vector2i(2, 0)] != null
	var bottom_right = data[Vector2i(1, 1)] != null
	var bottom = data[Vector2i(0, 1)] != null
	var bottom_left = data[Vector2i(-1, 1)] != null
	var left = data[Vector2i(-1, 0)] != null
	var left_left = data[Vector2i(-2, 0)] != null
	
	if pos.y >= -1:
		bottom_left = true
		bottom = true
		bottom_right = true
	if pos.x <= 0:
		top_left = true
		left = true
		bottom_left = true
	if pos.x <= 1:
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
