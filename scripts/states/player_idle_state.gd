class_name PlayerIdleState
extends State
## Provides a basic idle behavior to the player.


func physics_process(entity: Node2D, _delta: float) -> Variant:
	# type hinting
	var player = entity as Player
	
	# player is jumping, go to the jumping state
	if Input.is_action_just_pressed("player_jump"):
		player.sounds.stream = preload("res://audio/player/jump.ogg")
		player.sounds.play()
		return PlayerJumpingState
	
	# decelerate
	player.velocity.x = move_toward(player.velocity.x, 0, player.deceleration)
	
	# moving, go to moving state
	if Input.get_axis("player_left", "player_right") != 0:
		return PlayerMovingState
	
	return
