class_name PlayerState
extends State

var player: Player


func _init() -> void:
	intended_class = Player


func start() -> Script:
	player = node as Player
	player.item_dropped.connect(item_dropped)
	if player.held_item != null:
		player.held_item.position = Vector2(
			Player.HELD_ITEM_OFFSET.x * player.direction,
			Player.HELD_ITEM_OFFSET.y)
	return


func end() -> void:
	player.item_dropped.disconnect(item_dropped)
	return


func input(event: InputEvent) -> Script:
	if event.is_action("player_run") and not event.is_pressed():
		player.drop_item()
	return


## Called when the player drops an item.
func item_dropped(held_item: Entity) -> void:
	player.sounds.stream = preload("uid://c345xnns7om3m")
	player.sounds.play()
	player.spawn_spin_thump(
			player.global_position.lerp(held_item.global_position, 0.5))
	player.sprite.speed_scale = 1
	player.sprite.play("kick")


## Checks what floor state the player should be in.
func move_check(event: InputEvent) -> Script:
	if event.is_action_pressed("player_jump"):
		return PlayerJumpingState
	
	if event.is_action_pressed("player_spin_jump"):
		player.just_fell = true
		return PlayerSpinJumpingState
	
	if event.is_action_pressed("player_left"):
		if Input.is_action_pressed("player_right"):
			return PlayerIdleState
		else:
			return PlayerMovingState
	
	if event.is_action_pressed("player_right"):
		if Input.is_action_pressed("player_left"):
			return PlayerIdleState
		else:
			return PlayerMovingState
	
	if event.is_action_released("player_left"):
		if Input.is_action_pressed("player_right"):
			return PlayerMovingState
		else:
			return PlayerIdleState
	
	if event.is_action_released("player_right"):
		if Input.is_action_pressed("player_left"):
			return PlayerMovingState
		else:
			return PlayerIdleState
	
	return null


## Transitions the held item between directions, if there is one. Must be called
## before [member Player.direction] is assigned so the method can compare the
## old value with the new one. [param direction] may be specified to not
## recalculate the new direction value.
func position_held_item(
		direction := Input.get_axis("player_left", "player_right")) -> void:
	if player.held_item == null:
		return
	if direction == 0:
		return
	if player.direction != direction:
		prints(direction, player.direction)
		var tween = player.create_tween()
		tween.tween_property(player.held_item, "position:x", 0, 0)
		tween.tween_interval(2/15.0)
		tween.tween_property(player.held_item, "position:x",
				Player.HELD_ITEM_OFFSET.x * direction, 0)
