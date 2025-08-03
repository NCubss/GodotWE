class_name PlayerMovingState
extends State
## Provides idle, walking and running behavior to the player.

var _skidding := false


func start(entity: Node2D) -> Variant:
	assert(entity is Player,
			"Using a player state on a non-player entity is not allowed")
	return


func physics_process(entity: Node2D, _delta: float) -> Variant:
	# type hinting
	var player = entity as Player
	
	var direction := Input.get_axis("player_left", "player_right")
	var running := Input.is_action_pressed("player_run")
	var max_speed = player.max_run_speed if running else player.max_walk_speed
	
	# player is idle, go to the idle state
	if direction == 0:
		return PlayerIdleState
	
	# player is jumping, go to the jumping state
	if Input.is_action_just_pressed("player_jump"):
		player.sounds.stream = preload("res://audio/player/jump.ogg")
		player.sounds.play()
		return PlayerJumpingState
	
	if _skidding:
		# skidding logic
		player.velocity.x = move_toward(
				player.velocity.x, 0, player.skid_deceleration)
		if player.velocity.x == 0 or direction == 0:
			_skidding = false
			if player.sounds.stream == preload("res://audio/player/skid.ogg"):
				player.sounds.stop()
	else:
		# normal logic
		if direction != 0:
			# accelerate
			player.velocity.x = move_toward(
					player.velocity.x,
					max_speed * direction,
					player.acceleration
			)
		elif player.is_on_floor():
			# decelerate
			player.velocity.x = move_toward(
					player.velocity.x, 0, player.deceleration
			)
	
	# check for skidding
	if (
			direction == -sign(player.velocity.x)
			and not _skidding
			and direction != 0
	):
		_skidding = true
		_do_skid_smoke(player)
		if player.p_meter > 5 and player.is_on_floor():
			player.sounds.stream = preload("res://audio/player/skid.ogg")
			player.sounds.play()
	
	_do_p_meter(player)
	return null


func _do_skid_smoke(player: Player) -> void:
	if _skidding and player.is_on_floor() and player.p_meter > 5:
		var smoke = preload("res://scenes/particles/skid_smoke.tscn") \
				.instantiate()
		smoke.position = player.position.floor()
		player.add_sibling(smoke)
		player.owner.move_child(smoke, player.get_index())
		get_tree().create_timer(0.1).timeout.connect(_do_skid_smoke)


func _do_p_meter(player: Player) -> void:
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
	
	print(player.p_meter)
