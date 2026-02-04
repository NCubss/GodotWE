class_name PlayerFallingState
extends State
## Provides a basic falling behavior to the player.

var _coyote_timer := -1.0


func _init() -> void:
	intended_class = Player


func start(entity: Node2D) -> Variant:
	var player = entity as Player

	# enable coyote time
	if player.just_fell:
		_coyote_timer = 0
		player.just_fell = false
	return


func physics_process(entity: Node2D, delta: float) -> Variant:
	# type hinting
	var player = entity as Player
	
	# check for void
	if player.global_position.y > player.VOID_LEVEL:
		return PlayerDeathState
	
	var direction = Input.get_axis("player_left", "player_right")
	var max_speed = (
			player.max_run_speed
			if Input.is_action_pressed("player_run")
			else player.max_walk_speed
	)
	
	if _coyote_timer != -1:
		_coyote_timer += delta
	
	# switch to other states
	if player.is_on_floor():
		if direction == 0:
			return PlayerIdleState
		else:
			return PlayerMovingState
	elif _coyote_timer <= player.coyote_time and Input.is_action_just_pressed("player_jump"):
		_coyote_timer = 0
		return PlayerJumpingState
	
	# accelerate
	if direction != 0:
		player.direction = direction
		player.velocity.x = move_toward(
				player.velocity.x,
				max_speed * direction,
				player.acceleration
		)
	
	# animations
	if _coyote_timer == -1 or (_coyote_timer > player.coyote_time):
		if player.velocity.y < 0:
			player.sprite.play("jump")
		else:
			player.sprite.play("fall")
		if direction < 0:
			player.sprite.flip_h = true
		elif direction > 0:
			player.sprite.flip_h = false
	return
