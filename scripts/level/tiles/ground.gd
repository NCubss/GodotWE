class_name GroundTile
extends StaticBody2D
## A connecting ground tile.

@onready var tex: AtlasTexture = $Sprite.texture


func _ready() -> void:
	refresh_sprite()


func _atlas(x: int, y: int) -> void:
	tex.region.position = Vector2(x, y) * 16


func _check(x: int, y: int) -> bool:
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position + Vector2(x * 16, y * 16)
	query.exclude = [get_rid()]
	var result = get_world_2d().direct_space_state.intersect_point(query, 1)
	return result.size() != 0 and result[0]["collider"] is GroundTile


func refresh_sprite() -> void:
	if get_parent() == null:
		_atlas(5, 10)
		return
	
	var top_left = _check(-1, -1)
	var top = _check(0, -1)
	var top_right = _check(1, -1)
	var right = _check(1, 0)
	var right_right = _check(2, 0)
	var bottom_right = _check(1, 1)
	var bottom = _check(0, 1)
	var bottom_left = _check(-1, 1)
	var left = _check(-1, 0)
	var left_left = _check(-2, 0)
	
	if global_position.y >= -16:
		bottom_left = true
		bottom = true
		bottom_right = true
	if global_position.x <= 0:
		top_left = true
		left = true
		bottom_left = true
	if global_position.x <= 16:
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
