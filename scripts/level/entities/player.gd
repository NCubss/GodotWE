class_name Player
extends Entity
## Represents a controllable player.

### Represents a powerup. Most of these are exclusive and can only be found in
### their respective game styles.
#enum Powerup {
	### The default powerup. Uses the small hitbox size.
	#SMALL,
	### The powerup obtained from the Super Mushroom ([Mushroom]). Uses the big
	### hitbox size.
	#SUPER,
	### The powerup obtained from the Fire Flower ([FireFlower]). Can shoot
	### fireballs. Uses the big hitbox size.
	#FIRE,
	### The powerup obtained from the Cape Feather ([CapeFeather]). Exclusive to
	### the [i]Super Mario World[/i] game style. Can spin to attack with the
	### cape. Can fly using the cape. Uses the big hitbox size.
	#CAPE,
	### The powerup obtained from the P-Balloon ([PBalloon]). Exclusive to the
	### [i]Super Mario World[/i] game style. Can fly in the cardinal and ordinal
	### directions.
	#P_BALLOON,
	### The powerup obtained from the Cloud Flower ([CloudFlower]). Exclusive to
	### the [i]Super Mario World[/i] game style. Can spin to summon a wide cloud
	### under the player's feet. Uses the big hitbox size.
	#CLOUD,
	### The powerup obtained from the Mega Mushroom ([MegaMushroom]). Exclusive
	### to the [i]Super Mario Bros.[/i] game style. Can destroy hard blocks and
	### kill enemies by falling on them. Uses the big hitbox size.
	#MEGA,
	### The powerup obtained from the Weird Mushroom ([WeirdMushroom]). Exclusive
	### to the [i]Super Mario Bros.[/i] game style. Can jump significantly
	### higher. Uses the big hitbox size.
	#WEIRD,
	### The powerup obtained from the Superball Flower ([SuperballFlower]).
	### Exclusive to the [i]Super Mario Bros.[/] game style. Can shoot superballs
	### that bounce off of walls. Uses the big hitbox size.
	#SUPERBALL,
	### The powerup obtained from the Master Sword ([MasterSword]). Exclusive to
	### the [i]Super Mario Bros.[/i] game style. Can attack with a sword,
	### ground-pound, use a shield, summon bombs and fire arrows. Uses the small
	### hitbox size.
	#LINK,
	### The powerup obtained from the Super Leaf ([SuperLeaf]). Exclusive to the
	### [i]Super Mario Bros. 3[/i] game style. Can spin to attack with the tail
	### and fly. Uses the big hitbox size.
	#RACCOON,
	### The powerup obtained from the Frog Suit ([FrogSuit]). Exclusive to the
	### [i]Super Mario Bros. 3[/i] game style. 
	#FROG,
	### The powerup obtained from the Hammer Suit ([HammerSuit]). Exclusive to
	### the [i]Super Mario Bros. 3[/i] game style.
	#HAMMER,
	### The powerup obtained from the Propeller Mushroom ([PropellerMushroom]).
	### Exclusive to the [i]New Super Mario Bros. U[/i] game style.
	#PROPELLER,
	### The powerup obtained from the Super Acorn ([SuperAcorn]). Exclusive to
	### the [i]New Super Mario Bros. U[/i] game style.
	#ACORN,
	### The powerup obtained from the Penguin Suit ([PenguinSuit]). Exclusive to
	### the [i]Nwe Super Mario Bros. U[/i] game style.
	#PENGUIN
#}

## The player's sprite.
@onready var sprite: AnimatedSpriteExt = %Sprite
## The player's sound player.
@onready var sounds: AudioStreamPlayer = %Sounds
## The player's state machine.
@onready var state_machine: StateMachine = %StateMachine

## The powerup the player will start with.
@export var starting_powerup: Powerup = SmallPowerup.new(self)

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
var stomp_bounce_speed := 235.5

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

## The player's P-Meter value, from 0 to 7.
var p_meter := 0
## The direction the player is facing. This value is either -1 or 1, and
## represents which side of the X axis is the player facing.
var direction := 1:
	set(value):
		if value != direction and _held_item != null:
			if held_item_tween is Tween and held_item_tween.is_running():
				held_item_tween.kill()
			held_item_tween = create_tween()
			held_item_tween.tween_property(self._held_item, "position", Vector2(0, -1.5), 0)
			held_item_tween.tween_interval(7/60.0)
			held_item_tween.tween_property(self._held_item, "position", Vector2(-11 * direction, -1.5), 0)
			direction = value
			
## Used in processing coyote time.
var just_fell := false
## The tween used to move the held item side to side when moving and turning.
var held_item_tween: Tween

var _powerup: Powerup
var _held_item: Entity = null
var _held_item_z_index: int
var _p_timer := 0.0


## The hitbox size used when the player is on a small powerup.
const SMALL_HITBOX_SIZE = Rect2(Vector2(0, -7.5), Vector2(12, 15))
## The hitbox size used when the player is on a big powerup.
const BIG_HITBOX_SIZE = Rect2(Vector2(0, -13.5), Vector2(12, 27))
const HELD_ITEM_OFFSET = Vector2(11, -1.5)
## The y height at which the player will be killed.
const VOID_LEVEL = 64


func _ready() -> void:
	_powerup = starting_powerup
	_powerup.start()


func _physics_process(delta: float) -> void:
	super(delta)
	if _held_item != null and not Input.is_action_pressed("player_run"):
		drop_item()
	_attempt_correction(delta, 2)
	move_and_slide()
	_powerup.physics_process(delta)
	_p_timer += delta


func _process(delta: float) -> void:
	_powerup.process(delta)


## Downgrades the player into a lower-tier powerup.
func damage() -> void:
	sounds.stream = load("uid://0nbemimuo3b6")
	sounds.play()


## Forcibly kills the player, regardless of any powerups.
func kill() -> void:
	state_machine.switch(PlayerDeathState)


## Sets the player's current [Powerup]. If [param animate] is [code]false[/code],
## the powering up animation will not be played.
func set_powerup(powerup: Powerup, animate := true) -> void:
	_powerup.end()
	powerup.start(animate)
	_powerup = powerup


## Gets the player's current [Powerup].
func get_powerup() -> Powerup:
	return _powerup


## Gives the player an item to hold.
func give_item(item: Entity) -> void:
	var pickup_comp = Utility.find_child_by_class(item, PickupComponent) \
			as PickupComponent
	assert(pickup_comp != null,
			"Attempting to give player item without it having a Pickup" +
			"Component")
	call_deferred("_deferred_hold", item, pickup_comp)


## Drops whatever item the player is currently holding and returns it. The
## release type ([enum PickupComponent.ReleaseType]) depends on what actions
## the player is currently executing.
func drop_item() -> Entity:
	if _held_item == null:
		return
	var pickup_comp = Utility.find_child_by_class(_held_item, PickupComponent) \
			as PickupComponent
	held_item_tween.kill()
	_held_item.reparent(get_parent())
	_held_item.position += Vector2(2, -1.5)
	_held_item.velocity = Vector2((120 + abs(velocity.x)) * direction, -60)
	_held_item.z_index = _held_item_z_index
	var coll = KinematicCollision2D.new()
	if _held_item.test_move(global_transform,
			_held_item.global_position - global_position, coll):
		_held_item.global_position = global_position + coll.get_travel()
	if pickup_comp != null:
		pickup_comp.dropped.emit(PickupComponent.ReleaseType.KICKED)
	var last_held = _held_item
	_held_item = null
	return last_held


## Spawns the spin thump effect at [param position] in global coordinates, at
## the player's feet by default.
func spawn_spin_thump(pos := global_position) -> void:
	var spin_thump = preload("res://scenes/particles/spin_thump.tscn") \
			.instantiate()
	get_parent().add_sibling(spin_thump)
	spin_thump.global_position = pos


func _just_collided(collision: KinematicCollision2D) -> void:
	var coll = collision.get_collider()
	if collision.get_normal().y == 1 and \
			(coll is CollisionObject2D and coll.collision_layer == 1):
		sounds.stream = load("uid://7ec5u6l30bgt")
		sounds.play()


func _attempt_correction(delta: float, amount: int) -> void:
	if (
			velocity.y < 0
			and test_move(global_transform, Vector2(0, velocity.y * delta))
	):
		for i in range(1, amount * 2 + 1):
			for j in [-1.0, 1.0]:
				if not test_move(
						global_transform.translated(Vector2(i * j / 2, 0)),
						Vector2(0, velocity.y * delta)
				):
					translate(Vector2(i * j / 2, 0))
					if velocity.x * j / 2 < 0:
						velocity.x = 0
					return


func _deferred_hold(item: Entity, pickup_comp: PickupComponent) -> void:
	item.reparent(self)
	item.position = HELD_ITEM_OFFSET * Vector2(direction, 1)
	_held_item = item
	_held_item_z_index = item.z_index
	item.z_index = GameConstants.Layers.Z_AFTER_PLAYER
	pickup_comp.picked_up.emit(self)
