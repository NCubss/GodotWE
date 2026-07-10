class_name Enemy
extends Entity
## Represents an enemy with configurable settings on how it interacts with the
## player.

## Defines what type of stomping is allowed on an enemy.
enum Stompability {
	## Allows the player to stomp this enemy with any kind of jump. Triggers the
	## [signal stomped] signal.
	STOMPABLE,
	## Allows the player to only recoil off the enemy with a spin jump. Triggers
	## the [signal stomped] signal.
	RECOIL,
	## Does not allow the player to stomp this enemy. Does not trigger the
	## [signal stomped] signal.
	NONE,
	## Does nothing; doesn't bounce the player and doesn't damage it. Triggers
	## the [signal stomped] signal.
	CUSTOM,
}

## Fired when the enemy is stomped on by the player. Only fires if 
signal stomped(player: Player)

## The hitbox [Area2D] this enemy will use to damage the player.
@export var hitbox: Area2D

## The stompability of this enemy.
var stomp_behavior := Stompability.STOMPABLE

var _player_stomped_on_enter := false


func kill() -> void:
	#var grav: GravityComponent
	#for i in get_children():
		#if i is GravityComponent:
			#grav = i
		#else:
			#i.process_mode = Node.PROCESS_MODE_DISABLED
	#var tween = create_tween()
	## shadows
	#tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	#tween.tween_property($Graphics, "rotation", 0, 0)
	#tween.tween_property($Graphics, "rotation", 2 * PI, 0.5)
	#tween.set_loops()
	#grav.gravity = Vector2(0, 10)
	var graphics = $Graphics.duplicate() as Node2D
	graphics.global_position = $Graphics.global_position
	graphics.name = "DeadEntity"
	graphics.z_index = GameConstants.Layers.Z_DEAD
	graphics.z_as_relative = false
	graphics.set_script(DeadEntity)
	graphics.velocity = Vector2(60 * -sign(Utility.id("player").velocity.x), -240)
	add_sibling(graphics)
	queue_free()


func _ready() -> void:
	if hitbox == null:
		push_warning("Enemy does not have a damage hitbox! ",
			"Please add one via the \"hitbox\" variable.")
		return
	hitbox.body_entered.connect(func(entity): _body_handling(true, entity))
	hitbox.body_exited.connect(func(entity): _body_handling(false, entity))
	stomped.connect(_stomped)
	$SlideComponent.turned.connect(_turned)


func _stomped(player: Player) -> void:
	match stomp_behavior:
		Stompability.STOMPABLE:
			player.bounce()
			if player.state_machine.current_state is PlayerJumpingState:
				player.sounds.stream = preload("uid://c345xnns7om3m")
				player.sounds.play()
				player.spawn_spin_thump()
			elif player.state_machine.current_state is PlayerSpinJumpingState:
				_spin_stomp()
		Stompability.RECOIL:
			if player.state_machine.current_state is PlayerSpinJumpingState:
				player.bounce()
				player.sounds.stream = preload("uid://e8157k7h45xi")
				player.sounds.play()
				player.spawn_spin_thump()
			else:
				player.damage()
		Stompability.NONE:
				player.damage()
		# Stompability.CUSTOM has no default behavior


func _spin_stomp() -> void:
	var spin_smoke = SpinSmoke.create()
	add_sibling(spin_smoke)
	spin_smoke.global_position = global_position
	spin_smoke.position.y -= 8
	queue_free()


func _turned(direction: Vector2) -> void:
	if direction == Vector2.LEFT:
		$Graphics/Sprite.flip_h = true
	elif direction == Vector2.RIGHT:
		$Graphics/Sprite.flip_h = false
	

func _physics_process(_delta: float) -> void:
	move_and_slide()


func _body_handling(entering: bool, body: Node2D) -> void:
	var player = body as Player
	if player == null:
		return
	if stomp_behavior == Stompability.NONE:
		if entering:
			player.damage()
		return
	var player_rect = Utility.get_bounding_box(player)
	player_rect.position -= player.global_position
	player_rect.position += player.previous_position
	var self_rect = Utility.get_bounding_box(self)
	
	if entering:
		_player_stomped_on_enter = true
	elif _player_stomped_on_enter:
		_player_stomped_on_enter = false
		return
	if player_rect.end.y < self_rect.position.y + 5:
		stomped.emit(player)
	else:
		player.damage()
