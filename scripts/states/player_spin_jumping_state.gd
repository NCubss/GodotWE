class_name PlayerSpinJumpingState
extends State
## Provides a spin jumping behavior to the player.

# The type of jump that should be buffered
enum _JumpBufferType {
	NONE,
	JUMP,
	SPIN_JUMP
}

var _long_jump: bool = false
var _grav_comp: GravityComponent
var _jump_buffer: _JumpBufferType = _JumpBufferType.NONE
var _jump_buffer_timer: float = 0.0

func _init() -> void:
	intended_class = Player

func start(entity: Node2D) -> Variant:
	super(entity)
	var player: Player = entity as Player
	player.is_spinning = true
	_long_jump = true
	_grav_comp = Utility.find_child_by_class(player, GravityComponent)

	# Animación siempre
	player.sprite.speed_scale = 1.0
	player.sprite.flip_h = false
	player.sprite.play("spin_jump")

	# Aplica la velocidad de salto: usa pending si existe, si no spin_jump_speed
	if player.has_pending_jump:
		player.velocity.y = -float(player.pending_jump_speed)
		player.has_pending_jump = false
	else:
		player.velocity.y = -float(player.spin_jump_speed)

	return null

func end(entity: Node2D) -> void:
	var player: Player = entity as Player
	player.is_spinning = false  # <- importante para no dejar el flag activo
	# reset gravity
	var grav: GravityComponent = Utility.find_child_by_class(player, GravityComponent)
	grav.gravity = Vector2(0.0, player.gravity)

func physics_process(entity: Node2D, delta: float) -> Variant:
	var player: Player = entity as Player
	
	var direction: float = Input.get_axis("player_left", "player_right")
	var max_speed: float
	if Input.is_action_pressed("player_run"):
		max_speed = float(player.max_run_speed)
	else:
		max_speed = float(player.max_walk_speed)
	
	# jump buffer
	if _jump_buffer != _JumpBufferType.NONE:
		_jump_buffer_timer += delta
		if _jump_buffer_timer > float(player.jump_buffer_time):
			_jump_buffer = _JumpBufferType.NONE

	if Input.is_action_just_pressed("player_jump"):
		_jump_buffer = _JumpBufferType.JUMP
		_jump_buffer_timer = 0.0
	elif Input.is_action_just_pressed("player_spin_jump"):
		_jump_buffer = _JumpBufferType.SPIN_JUMP
		_jump_buffer_timer = 0.0
	
	# Mantener long jump si se mantiene jump o spin_jump
	var holding_jump: bool = (
		Input.is_action_pressed("player_spin_jump")
		or Input.is_action_pressed("player_jump")
	)
	if (not holding_jump) or (player.velocity.y >= -float(player.long_jump_stop_speed)):
		_long_jump = false
	
	# Cambios de estado en piso
	if player.is_on_floor():
		if _jump_buffer == _JumpBufferType.JUMP:
			player.sounds.stream = preload("res://audio/player/jump.ogg")
			player.sounds.play()
			return PlayerJumpingState
		elif _jump_buffer == _JumpBufferType.SPIN_JUMP:
			player.sounds.stream = preload("res://audio/player/spin_jump.ogg")
			player.sounds.play()
			return PlayerSpinJumpingState
		else:
			if direction == 0.0:
				return PlayerIdleState
			else:
				return PlayerMovingState
	
	# Gravedad variable para long jump
	if _long_jump:
		_grav_comp.gravity = Vector2(0.0, float(player.long_jump_gravity))
	else:
		_grav_comp.gravity = Vector2(0.0, float(player.gravity))
	
	# Aceleración horizontal
	if direction != 0.0:
		player.direction = int(sign(direction))  # conserva -1/1 para tu lógica
		player.velocity.x = move_toward(
			player.velocity.x,
			max_speed * direction,
			float(player.acceleration)
		)
	
	return null
