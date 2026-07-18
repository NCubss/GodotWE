class_name Player
extends Entity
## Represents a controllable player.

## Emitted when the [member held_item] is dropped.
signal item_dropped(item: Entity)
## Emitted when an item is given to the player.
signal item_given

## The player's sprite.
@onready var sprite: AnimatedSprite2D = %Sprite
## The player's sound player.
@onready var sounds: AudioStreamPlayer = %Sounds
## The player's state machine.
@onready var state_machine: StateMachine = %StateMachine

## The powerup the player will start with.
@export var starting_powerup: Powerup = SmallPowerup.new():
	set(v):
		v.player = self
		starting_powerup = v

#region Physics values

@export_group("Maximum Speed")
## The maximum horizontal speed when walking.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_walk_speed := 78.0
## The maximum horizontal speed when running.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_run_speed := 180.0
## The maximum vertical speed when falling.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_fall_speed := 258.0

@export_group("Acceleration")
## The usual horizontal acceleration speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var acceleration := 3.6
## Acceleration speed used when the player is on a slippery surface.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var ice_acceleration := 0.36

@export_group("Deceleration")
## The usual horizontal deceleration speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var deceleration := 3.0
## Deceleration speed used when the player is on a slippery surface.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var ice_deceleration := 0.3
## Deceleration speed used when the player is skidding. The player does not
## accelerate using this value.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var skid_deceleration := 7.8

@export_group("Jump Speed")
## Jump speed used when the horizontal speed is equal to or above
## [member Player.max_run_speed].
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var fast_jump_speed := 258.0
## Jump speed used when the horizontal speed is equal to or above
## [member Player.max_walk_speed] when walking, below
## [member Player.max_run_speed] when running.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var slow_jump_speed := 243.0
## Jump speed used when the horizontal speed is below
## [member Player.max_walk_speed].
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var idle_jump_speed := 237.0
## The vertical speed at which the player will start applying
## [member Player.gravity] instead of [member Player.long_jump_gravity].
## Includes spin jumps.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var long_jump_stop_speed := 60.0
## The regular spin jump speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var spin_jump_speed := 198.0
## The spin jump speed used when the level has low gravity.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var night_spin_jump_speed := 138.0
## The bounce speed used when an enemy is stomped.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var stomp_bounce_speed := 253.5

@export_group("Gravity")
## The default gravity.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var gravity := 18.0
## The gravity used for variable jump height.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var long_jump_gravity := 6.0

@export_group("Enhancements")
## The amount of body corner overlap to push the player to the side. Only
## applied on the Y axis.
@export_custom(PROPERTY_HINT_NONE, "suffix:px")
var corner_correction := 3
## The maximum amount of time the player will allow when it has jumped
## too [i]early[/i].
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var jump_buffer_time := 2.0/60
## The maximum amount of time the player will allow when it has jumped too
## [i]late[/i].
@export_custom(PROPERTY_HINT_NONE, "suffix:s")
var coyote_time := 4.0/60

#endregion

## The player's collected coin count.
var coins := 0
## The player's P-Meter value, from 0 to 7.
var p_meter := 0
## The direction the player is facing. This value is either -1 or 1, and
## represents which side of the X axis is the player facing.
var direction := 1
## Used in processing coyote time.
var just_fell := false
## The player's [b]global[/b] position before the [method move_and_slide] call.
## Used in scenarios where
## [url=https://github.com/godotengine/godot/issues/38983]Godot's area detection
## is late[/url].
var previous_position: Vector2
## The tween used to move the held item side to side when moving and turning.
var held_item_tween: Tween

var _powerup: Powerup
var held_item: Entity = null:
	set = give_item
var _p_timer := 0.0
var _can_move_camera_up := false
var _held_z := 0


## The hitbox size used when the player is on a small powerup.
const SMALL_HITBOX_SIZE = Rect2(Vector2(0, -7.5), Vector2(12, 15))
## The hitbox size used when the player is on a big powerup.
const BIG_HITBOX_SIZE = Rect2(Vector2(0, -13.5), Vector2(12, 27))
const HELD_ITEM_OFFSET = Vector2(11, -1.5)
## The y height at which the player will be killed.
const VOID_LEVEL = 64


func _ready() -> void:
	if not level.is_node_ready():
		await level.ready
	level.hud.player = self
	
	# trigger setter
	starting_powerup = starting_powerup
	_powerup = starting_powerup
	_powerup.start()
	
	var f = func():
		var query = PhysicsShapeQueryParameters2D.new()
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = 1
		query.shape = WorldBoundaryShape2D.new()
		query.shape.normal = Vector2.DOWN
		query.transform.origin = Vector2(0, -14 * Level.GRID_SIZE.y)
		_can_move_camera_up = not get_world_2d().direct_space_state.intersect_shape(
				query, 1).is_empty()
	f.call_deferred()


func _physics_process(delta: float) -> void:
	previous_position = global_position
	_p_timer += delta
	
	_powerup.physics_process(delta)
	_attempt_correction(delta, 2)
	move_and_slide()
	super(delta)
	
	if global_position.y >= VOID_LEVEL:
		state_machine.switch(PlayerDeathState)


func _process(delta: float) -> void:
	_powerup.process(delta)
	# avoid moving the camera during pauses
	if level.can_process():
		var size = get_viewport().get_visible_rect().size / Utility.camera_scale
		var center = global_position - (size / 2)
		var target = Vector2(center.x, Utility.camera_position.y)
		if _can_move_camera_up or Utility.camera_position.y < center.y:
			if Utility.camera_position.y - center.y <= -32:
				target.y = center.y - 32
			if center.y - Utility.camera_position.y <= -32:
				target.y = center.y + 32
		# uncomment to smooth when camera hits edges
		#target = target.clamp(
				#Vector2(0, -Level.LEVEL_HEIGHT * Level.GRID_SIZE.y),
				#Vector2(INF, -get_viewport().get_visible_rect().size.y \
				#/ Utility.camera_scale.y))
		Utility.camera_position = Utility.camera_position.lerp(target, 6 * delta)


## Makes the player bounce (e.g. off an enemy).
func bounce() -> void:
	if state_machine.current_state is PlayerSpinJumpingState:
		state_machine.switch(PlayerSpinJumpingState)
	else:
		state_machine.switch(PlayerJumpingState)
	sounds.stop()
	velocity.y = -stomp_bounce_speed
	# SMM:WE oddity
	position.y -= 1


## Downgrades the player into a lower-tier powerup.
func damage() -> void:
	if is_queued_for_deletion():
		return
	if _powerup is SmallPowerup:
		kill()
	else:
		sounds.stream = preload("uid://0nbemimuo3b6")
		sounds.play()


## Forcibly kills the player, regardless of any powerups.
func kill() -> void:
	state_machine.switch(PlayerDeathState)


## Sets the player's current [Powerup]. If [param animate] is [code]false[/code],
## the powering up animation will not be played.
func set_powerup(powerup: Powerup, animate := true) -> void:
	_powerup.end()
	powerup.player = self
	powerup.start(animate)
	_powerup = powerup


## Gets the player's current [Powerup].
func get_powerup() -> Powerup:
	return _powerup


## Gives the player an item to hold. This is equivalent to setting [member
## held_item] to [param item].
func give_item(item: Entity) -> void:
	if held_item == item:
		return
	var pickup: PickupComponent
	if held_item != null:
		pickup = Utility.find_child_by_class(held_item, PickupComponent)
		if pickup != null:
			held_item.reparent.call_deferred(get_parent())
			var release_type
			# TODO: implement DROPPED when ducking is added
			if Input.is_action_pressed("player_up"):
				release_type = PickupComponent.ReleaseType.THROWN_UP
			else:
				release_type = PickupComponent.ReleaseType.KICKED
			var old_item = held_item
			held_item.z_index = _held_z
			held_item = null
			pickup.dropped.emit.call_deferred(self, release_type)
			item_dropped.emit.call_deferred(old_item)
		if item == null:
			return
	pickup = Utility.find_child_by_class(item, PickupComponent)
	if pickup == null:
		push_warning("Given item does not have PickupComponent, cannot give.")
		return
	if not pickup.can_be_held:
		push_warning("Can't hold this item.")
		return
	held_item = item
	if item.get_parent() == null:
		add_child(item)
	else:
		item.reparent.call_deferred(self)
	_held_z = held_item.z_index
	held_item.z_index = GameConstants.Layers.Z_AFTER_PLAYER
	pickup.picked_up.emit.call_deferred(self)
	item_given.emit.call_deferred()


## Drops whatever item the player is currently holding. This is different from
## setting [member held_item] to [code]null[/code] as it returns the dropped
## item. The release type ([enum PickupComponent.ReleaseType]) depends on what
## actions the player is currently executing.
func drop_item() -> Entity:
	var item = held_item
	held_item = null
	return item


## Spawns the spin thump effect at [param position] in global coordinates, at
## the player's feet by default.
func spawn_spin_thump(pos := global_position) -> void:
	var spin_thump = preload("uid://clqrm38rakunb").instantiate()
	get_parent().add_sibling(spin_thump)
	spin_thump.global_position = pos


## Used in the state machine to determine whether it can change to another
## animation.
func can_change_sprite() -> bool:
	return not (sprite.animation == &"kick" and sprite.is_playing())


func _just_collided(collision: KinematicCollision2D) -> void:
	var coll = collision.get_collider()
	if collision.get_normal().y == 1 and \
			(coll is CollisionObject2D and coll.collision_layer == 1):
		sounds.stream = preload("uid://7ec5u6l30bgt")
		sounds.play()


func _attempt_correction(delta: float, amount: int) -> void:
	if velocity.y < 0 and test_move(
			global_transform, Vector2(0, velocity.y * delta)):
		for i in range(1, amount * 2 + 1):
			for j in [-1.0, 1.0]:
				if not test_move(global_transform.translated(
						Vector2(i * j / 2, 0)), Vector2(0, velocity.y * delta)):
					position += Vector2(i * j / 2, 0)
					if velocity.x * j / 2 < 0:
						velocity.x = 0
					return
