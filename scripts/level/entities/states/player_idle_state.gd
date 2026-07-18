class_name PlayerIdleState
extends PlayerState
## Provides a basic idle behavior to the player.


func physics_process(delta: float) -> Script:
	super(delta)
	
	# player is not on floor, go to the falling state
	if not player.is_on_floor():
		return PlayerFallingState
	
	# decelerate
	player.velocity.x = move_toward(player.velocity.x, 0, player.deceleration)
	
	# animations
	if player.can_change_sprite():
		if player.velocity.x == 0:
			player.sprite.speed_scale = 1
			if Input.is_action_pressed("player_up"):
				if player.held_item == null:
					player.sprite.play("look_up")
				else:
					player.sprite.play("hold_look_up")
			else:
				if player.held_item == null:
					player.sprite.play("idle")
				else:
					player.sprite.play("hold_idle")
		else:
			player.sprite.speed_scale = abs(player.velocity.x) * 12 * delta
			if player.held_item == null:
				if player.p_meter > 5:
					player.sprite.play("run")
				else:
					player.sprite.play("walk")
			else:
				player.sprite.play("hold_walk")
	
	return null


func input(event: InputEvent) -> Script:
	super(event)
	return move_check(event)
