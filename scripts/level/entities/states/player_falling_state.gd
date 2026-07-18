class_name PlayerFallingState
extends PlayerState
## Provides a basic falling behavior to the player.

var _coyote_timer := -1.0


func start() -> Script:
	super()
	# enable coyote time
	if player.just_fell:
		_coyote_timer = 0
		player.just_fell = false
	return null


func physics_process(delta: float) -> Script:
	super(delta)
	
	var direction = Input.get_axis("player_left", "player_right")
	var max_speed = player.max_run_speed \
			if Input.is_action_pressed("player_run") \
			else player.max_walk_speed
	
	if _coyote_timer != -1:
		_coyote_timer += delta
	
	if _coyote_timer <= player.coyote_time \
			and Input.is_action_just_pressed("player_jump"):
		_coyote_timer = 0
		return PlayerJumpingState
	
	position_held_item(direction)
	
	# accelerate
	if direction != 0:
		player.direction = int(direction)
		player.velocity.x = move_toward(
				player.velocity.x,
				max_speed * direction,
				player.acceleration)
	
	
	if player.is_on_floor():
		if direction == 0:
			return PlayerIdleState
		else:
			return PlayerMovingState
	
	# animations
	if player.can_change_sprite():
		if _coyote_timer == -1 or (_coyote_timer > player.coyote_time):
			if player.velocity.y < 0:
				player.sprite.play("jump")
			else:
				player.sprite.play("fall")
			if direction < 0:
				player.sprite.flip_h = true
			elif direction > 0:
				player.sprite.flip_h = false
	return null


func input(event: InputEvent) -> Script:
	super(event)
	
	if player.is_on_floor():
		return move_check(event)
	
	return null
