class_name PlayerSpinJumpingState
extends State
## Provides a spin jumping behavior to the player.

# The type of jump that should be buffered
enum _JumpBufferType {
	NONE,
	JUMP,
	SPIN_JUMP
}

var _long_jump := false
var _grav_comp: GravityComponent
var _jump_buffer: _JumpBufferType
var _jump_buffer_timer := 0.0


func _init() -> void:
	intended_class = Player


func start(entity: Node2D) -> Variant:
	super(entity)
	var player = entity as Player
	_long_jump = true
	_grav_comp = Utility.find_child_by_class(player, GravityComponent)
	
	# animations
	player.sprite.speed_scale = 1
	player.sprite.flip_h = false
	player.sprite.play("spin_jump")
	
	# apply jump speed
	player.velocity.y = -player.spin_jump_speed
	
	return


func end(entity: Node2D) -> void:
	# type hinting
	var player = entity as Player
	
	# reset gravity
	var grav = Utility.find_child_by_class(player, GravityComponent)
	grav.gravity = Vector2(0, player.gravity)


func physics_process(entity: Node2D, delta: float) -> Variant:
	# type hinting
	var player = entity as Player
	
	var direction = Input.get_axis("player_left", "player_right")
	var max_speed = (
			player.max_run_speed
			if Input.is_action_pressed("player_run")
			else player.max_walk_speed
	)
	
	# jump buffer stuff
	if _jump_buffer != _JumpBufferType.NONE:
		_jump_buffer_timer += delta
		# time's up!
		if _jump_buffer_timer > player.jump_buffer_time:
			_jump_buffer = _JumpBufferType.NONE
	if Input.is_action_just_pressed("player_jump"):
		_jump_buffer = _JumpBufferType.JUMP
		_jump_buffer_timer = 0
	elif Input.is_action_just_pressed("player_spin_jump"):
		_jump_buffer = _JumpBufferType.SPIN_JUMP
		_jump_buffer_timer = 0
	
	if (
		not Input.is_action_pressed("player_spin_jump")
		or player.velocity.y >= -player.long_jump_stop_speed
	):
		_long_jump = false
	
	# switch to other states
	if player.is_on_floor():
		# jump if the player jumped close enough
		if _jump_buffer == _JumpBufferType.JUMP:
			player.sounds.stream = preload("res://audio/player/jump.ogg")
			player.sounds.play()
			return PlayerJumpingState
		elif _jump_buffer == _JumpBufferType.SPIN_JUMP:
			player.sounds.stream = preload("res://audio/player/spin_jump.ogg")
			player.sounds.play()
			return PlayerSpinJumpingState
		else:
			if direction == 0:
				return PlayerIdleState
			else:
				return PlayerMovingState
	
	# change gravity for variable jump height
	if _long_jump:
		_grav_comp.gravity = Vector2(0, player.long_jump_gravity)
	else:
		_grav_comp.gravity = Vector2(0, player.gravity)
	
	# accelerate
	if direction != 0:
		player.direction = direction
		player.velocity.x = move_toward(
				player.velocity.x,
				max_speed * direction,
				player.acceleration
		)
	
	return
