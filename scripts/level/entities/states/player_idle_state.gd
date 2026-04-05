class_name PlayerIdleState
extends State
## Provides a basic idle behavior to the player.


func _init() -> void:
	intended_class = Player


func physics_process(entity: Node2D, delta: float) -> Variant:
	# type hinting
	var player = entity as Player
	
	# check for void
	if player.global_position.y > player.VOID_LEVEL:
		return PlayerDeathState
	
	# player is not on floor, go to the falling state
	if not player.is_on_floor():
		return PlayerFallingState
	
	# decelerate
	player.velocity.x = move_toward(player.velocity.x, 0, player.deceleration)
	
	# animations
	if player.velocity.x == 0:
		player.sprite.speed_scale = 1
		player.sprite.play("idle")
	else:
		player.sprite.speed_scale = abs(player.velocity.x) * 12 * delta
		if player.p_meter > 5:
			player.sprite.play("run")
		else:
			player.sprite.play("walk")
	
	return


func input(entity: Node2D, event: InputEvent) -> Variant:
	# type hinting
	var player = entity as Player
	
	# player is jumping, go to jumping state
	if event.is_action_pressed("player_jump"):
		return PlayerJumpingState
	
	# player is spin jumping, go to the spin jumping state
	if event.is_action_pressed("player_spin_jump"):
		player.just_fell = true
		return PlayerSpinJumpingState
	
	# moving, go to moving state
	if Input.get_axis("player_left", "player_right") != 0:
		return PlayerMovingState
	
	return
