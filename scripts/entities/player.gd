class_name Player
extends CharacterBodyExt
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
@onready var graphics: Node = %Graphics
@onready var state_machine: StateMachine = %StateMachine

## The player's current powerup.
@export var _powerup: Powerup = SmallPowerup.new(self)

@export_group("Maximum Speed")
## The maximum horizontal speed when walking.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_walk_speed := 78.0
## The maximum horizontal speed when running.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_run_speed := 180.0
## The maximum vertical speed when falling.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var max_fall_speed = 258.0

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
var _p_timer := 0.0
# For coyote time
@warning_ignore("unused_private_class_variable")
var _just_fell := false

const SMALL_HITBOX_SIZE = Rect2(Vector2(0, -7.5), Vector2(12, 15))
const BIG_HITBOX_SIZE = Rect2(Vector2(0, -13.5), Vector2(12, 27))


func set_powerup(powerup: Powerup, animate := false) -> void:
	_powerup.end()
	powerup.start(animate)
	_powerup = powerup


func get_powerup() -> Powerup:
	return _powerup


func damage() -> void:
	sounds.stream = preload("res://audio/player/warp.ogg")
	sounds.play()


func kill() -> void:
	sounds.stream = preload("res://audio/player/dead.ogg")
	sounds.play()


func _ready() -> void:
	_powerup.start()
	print($CollShape.shape.get_rect())


func _physics_process(delta: float) -> void:
	super(delta)
	_attempt_correction(delta, 2)
	move_and_slide()
	_powerup.physics_process(delta)
	_p_timer += delta


func _process(delta: float) -> void:
	_powerup.process(delta)


func _just_collided(collision: KinematicCollision2D) -> void:
	if collision.get_normal().y == 1:
		$Sounds.stream = preload("res://audio/player/bump.ogg")
		$Sounds.play()


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
