class_name Player
extends CharacterBodyExt
## Represents a controllable player.

## The player's sprite.
@onready var sprite: AnimatedSpriteExt = %Sprite
## The player's sound player.
@onready var sounds: AudioStreamPlayer = %Sounds

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
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s")
var long_jump_stop_speed := 60.0

@export_group("Gravity")
## The default gravity.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var gravity = 18.0
## The gravity used for variable jump height.
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s²")
var long_jump_gravity = 6.0

## The player's P-Meter value, from 0 to 7.
var p_meter := 0
var _p_timer := 0.0

var skidding := false
var long_jump := false
var can_jump := false
var spin_jump := false

func _physics_process(delta: float) -> void:
	super(delta)
	_attempt_correction(delta, 2)
	move_and_slide()
	_p_timer += delta
#
	#var direction := Input.get_axis("player_left", "player_right")
	#var running := Input.is_action_pressed("player_run")
	#var ducking := Input.is_action_pressed("player_down")
	#can_jump = is_on_floor()
#
	#if spin_jump and is_on_floor():
		#spin_jump = false
#
	#$CollShapeNormal.disabled = ducking
	#$CollShapeDucking.disabled = not ducking
#
	#velocity.y = min(velocity.y + (LONG_JUMP_GRAVITY if long_jump else GRAVITY), MAX_FALL_SPEED)
#
	#if Input.is_action_just_pressed("player_spin_jump") and can_jump:
		#long_jump = true
		#spin_jump = true
		#if not running and velocity.y < WALK_SPEED:
			#velocity.y = -IDLE_JUMP_SPEED
		#elif (not running and velocity.y >= WALK_SPEED) or (running and velocity.y < RUN_SPEED):
			#velocity.y = -SLOW_JUMP_SPEED
		#elif running and velocity.y >= RUN_SPEED:
			#velocity.y = -FAST_JUMP_SPEED
		#$Sounds.stream = preload("res://audio/player/spin_jump.ogg")
		#$Sounds.play()
#
	#if Input.is_action_just_pressed("player_jump") and can_jump:
		#long_jump = true

		#$Sounds.stream = preload("res://audio/player/jump.ogg")
		#$Sounds.play()
#
	#if long_jump and (velocity.y > -60 or not (Input.is_action_pressed("player_jump") or Input.is_action_pressed("player_spin_jump"))):
		#long_jump = false
#
	## SPRITE ANIMATION LOGIC
	## Set default speed scale
	#$Sprite.speed_scale = 1
#
	#if velocity.x == 0 or is_on_wall():
		#$Sprite.play("idle")
	#else:
		#if p_meter > 5:
			#$Sprite.play("run")
		#else:
			#$Sprite.play("walk")
		#$Sprite.speed_scale = abs(velocity.x) * 12 * delta
		#if direction == -1:
			#$Sprite.flip_h = true
		#elif direction == 1:
			#$Sprite.flip_h = false
#
	#if not can_jump:
		#if spin_jump:
			#if $Sprite.animation != "spin_jump":
				#$Sprite.play("spin_jump")
				#$Sprite.speed_scale = 2
		#else:
			#if p_meter > 5:
				#$Sprite.play("p_jump")
			#else:
				#if velocity.y < 0:
					#$Sprite.play("jump")
				#else:
					#$Sprite.play("fall")
#
	#if can_jump and ducking:
		#$Sprite.play("duck")
#
	#if skidding and is_on_floor() and p_meter > 5:
		#$Sprite.play("skid")
#
	## P-Meter Logic
	#do_p_meter(delta)
	
	#adaprint("%.2f" % (velocity.x * delta))
	#print("%.2f" % (velocity.y * delta))

func _process(_delta: float) -> void:
	$Sprite.position = Vector2(-fmod(position.x, 1), -fmod(position.y, 1) - 15)
	$Camera2D.position = Vector2(-fmod(position.x, 1), -fmod(position.y, 1))


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
