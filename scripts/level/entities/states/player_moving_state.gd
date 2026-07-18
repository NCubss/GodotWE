class_name PlayerMovingState
extends PlayerState
## Provides idle, walking and running behavior to the player.

var _skidding := false


func end() -> void:
	super()
	player.sprite.speed_scale = 1
	_skidding = false


func physics_process(delta: float) -> Script:
	super(delta)
	
	var direction := Input.get_axis("player_left", "player_right")
	var running := Input.is_action_pressed("player_run")
	var max_speed = player.max_run_speed if running else player.max_walk_speed
	
	if not player.is_on_floor():
		player.just_fell = true
		return PlayerFallingState
	
	position_held_item(direction)
	
	if _skidding:
		player.velocity.x = move_toward(
				player.velocity.x, 0, player.skid_deceleration)
		if player.velocity.x == 0 or direction == 0:
			_skidding = false
			if player.sounds.stream == preload("uid://vxfegf1r2emq"):
				player.sounds.stop()
	else:
		if direction != 0:
			player.direction = int(direction)
			player.velocity.x = move_toward(
					player.velocity.x,
					max_speed * direction,
					player.acceleration)
		elif player.is_on_floor():
			player.velocity.x = move_toward(player.velocity.x, 0,
					player.deceleration)
	
	if direction == -sign(player.velocity.x) and not _skidding \
			and direction != 0:
		_skidding = true
		_do_skid_smoke()
		if player.p_meter > 5 and player.is_on_floor():
			player.sounds.stream = preload("uid://vxfegf1r2emq")
			player.sounds.play()
	
	# animations
	if player.can_change_sprite():
		if player.is_on_wall():
			if player.held_item == null:
				player.sprite.play("idle")
			else:
				player.sprite.play("hold_idle")
		else:
			player.sprite.speed_scale = abs(player.velocity.x) * 12 * delta
			if player.held_item != null:
				player.sprite.play("hold_walk")
			elif player.p_meter > 5:
				player.sprite.play("run")
			else:
				player.sprite.play("walk")
	if direction < 0:
		player.sprite.flip_h = true
	elif direction > 0:
		player.sprite.flip_h = false
	
	return null


func input(event: InputEvent) -> Script:
	super(event)
	return move_check(event)


func _do_skid_smoke() -> void:
	if _skidding and player.is_on_floor() and player.p_meter > 5:
		var smoke = preload("uid://bde0tltjb5047").instantiate()
		smoke.position = player.position
		
		player.add_sibling(smoke)
		player.get_parent().move_child(smoke, player.get_index())
		get_tree().create_timer(0.1).timeout.connect(_do_skid_smoke)


## Basic P-Meter logic.
func do_p_meter() -> void:
	if player._p_timer != 0 and (player.velocity.x != 0 or player.p_meter != 0):
		player._p_timer = 0
	
	if abs(player.velocity.x) > player.max_walk_speed or not player.is_on_floor():
		if player._p_timer > 0.2:
			player._p_timer = 0
		if player.p_meter <= 5 and player._p_timer >= 0.133 and player.is_on_floor():
			player.p_timer = 0
			player.p_meter += 1
		if player.p_meter == 6 and player._p_timer >= 0.116:
			player.p_timer = 0
			player.p_meter += 1
		elif player.p_meter == 7 and player._p_timer >= 0.116:
			player._p_timer = 0
	
	if abs(player.velocity.x) <= player.max_walk_speed and player.is_on_floor():
		if player.p_meter > 5:
			player.p_meter = 5
		if player._p_timer >= 0.4:
			player._p_timer = 0
			player.p_meter -= 1
