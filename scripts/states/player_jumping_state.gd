class_name PlayerJumpingState
extends State
## Provides jumping behavior to the player.

var _long_jump := false


func start(entity: Node2D) -> Variant:
	# type hinting
	var player = entity as Player
	
	var running = Input.is_action_pressed("player_run")
	_long_jump = true
	
	# apply jump speed
	if not running and player.velocity.y < player.max_walk_speed:
		player.velocity.y = -player.idle_jump_speed
	elif (
			(not running and player.velocity.y >= player.max_walk_speed)
			or (running and player.velocity.y < player.max_run_speed)
	):
		player.velocity.y = -player.slow_jump_speed
	elif running and player.velocity.y >= player.max_run_speed:
		player.velocity.y = -player.fast_jump_speed
	
	return


func physics_process(entity: Node2D, _delta: float) -> Variant:
	# type hinting
	var player = entity as Player
	
	var direction = Input.get_axis("player_left", "player_right")
	var max_speed = (
			player.max_run_speed
			if Input.is_action_pressed("player_run")
			else player.max_walk_speed
	)
	
	if player.velocity.y >= 0 or player.is_on_floor():
		if direction == 0:
			return PlayerIdleState
		else:
			return PlayerMovingState
	
	if (
		not Input.is_action_pressed("player_jump")
		or player.velocity.y >= -player.long_jump_stop_speed
	):
		_long_jump = false
	
	# change gravity for variable jump height
	var grav = Utility.find_child_by_class(player, GravityComponent) \
			as GravityComponent
	if _long_jump:
		grav.gravity = Vector2(0, player.long_jump_gravity)
	else:
		grav.gravity = Vector2(0, player.gravity)
	
	# accelerate
	if direction != 0:
		player.velocity.x = move_toward(
				player.velocity.x,
				max_speed * direction,
				player.acceleration
		)
	
	return
