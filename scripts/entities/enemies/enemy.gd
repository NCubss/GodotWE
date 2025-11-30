class_name Enemy
extends Entity
## Represents an enemy with configurable settings on how it interacts with the
## player.

## Defines what type of stomping is allowed on an enemy.
enum Stompability {
	## Allows the player to stomp this enemy with any kind of jump. Triggers the
	## [signal Enemy.stomped] signal.
	STOMPABLE,
	## Allows the player to stomp this enemy only with a spin jump. Triggers the
	## [signal Enemy.stomped] signal.
	SPIN_JUMP_ONLY,
	## Does not allow the player to stomp this enemy. Does not trigger the
	## [signal Enemy.stomped] signal.
	NONE,
}

## Fired when the enemy is stomped on by the player. Only fires if 
signal stomped(player: Player)

## The hitbox [Area2D] this enemy will use to damage the player.
@export var hitbox: Area2D

## The stompability of this enemy.
var stomp_behavior: Stompability

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
	player.velocity.y = -player.stomp_bounce_speed
	player.sounds.stream = preload("res://audio/player/klock.ogg")
	player.sounds.play()
	var spin_thump = preload("res://scenes/particles/spin_thump.tscn") \
		.instantiate()
	player.state_machine.switch(PlayerJumpingState)
	call_deferred("add_sibling", spin_thump)
	spin_thump.global_position = player.global_position
	kill()


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
	var player_coll_shape = Utility.find_child_by_class(player,
			CollisionShape2D) as CollisionShape2D
	if player_coll_shape == null:
		return
	var player_rect = player_coll_shape.shape.get_rect()
	player_rect.position += player_coll_shape.global_position
	var self_coll_shape = Utility.find_child_by_class(self,
			CollisionShape2D) as CollisionShape2D
	if self_coll_shape == null:
		return
	var self_rect = self_coll_shape.shape.get_rect()
	self_rect.position += self_coll_shape.global_position
	if player_rect.end.y < self_rect.position.y + 8:
		if entering:
			_player_stomped_on_enter = true
		elif _player_stomped_on_enter:
			_player_stomped_on_enter = false
			return
		stomped.emit(player)
	else:
		player.damage()
