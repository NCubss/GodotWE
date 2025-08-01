class_name Player
extends CharacterBodyExt
## Represents a controllable player.

const WALK_SPEED = 78
const RUN_SPEED = 180

const ACCEL = 3.6
const ICE_ACCEL = 0.36
const SKID_ACCEL = 7.8

const DECEL = 3
const ICE_DECEL = 0.3

const FAST_JUMP_SPEED = 258
const SLOW_JUMP_SPEED = 243
const IDLE_JUMP_SPEED = 237

const GRAVITY = 18
const LONG_JUMP_GRAVITY = 6
const MAX_FALL_SPEED = 258

const COYOTE_TIME = 3

var p_meter := 0
var p_timer := 0
var p_timer_enabled := false
var p_extra_timer := 0
var p_extra_timer_enabled := false

var skidding := false
var long_jump := false
var can_jump := false

func _ready() -> void:
	Engine.time_scale = 0.1
	pass

func _physics_process(delta: float) -> void:
	super(delta)
	move_and_slide()
	var direction := Input.get_axis("player_left", "player_right")
	var running := Input.is_action_pressed("player_run")
	var ducking := Input.is_action_pressed("player_down")
	can_jump = is_on_floor()
	
	$CollShapeNormal.disabled = ducking
	$CollShapeDucking.disabled = not ducking
	
	var max_speed = (RUN_SPEED if Input.is_action_pressed("player_run") else WALK_SPEED)
	
	if skidding:
		velocity.x = move_toward(velocity.x, 0, SKID_ACCEL)
		if direction == 0 or velocity.x == 0:
			skidding = false
			if $Sounds.stream == preload("res://audio/player/skid.ogg"):
				$Sounds.stop()
	else:
		if direction != 0 and not (Input.is_action_pressed("player_down") and can_jump):
			velocity.x = move_toward(velocity.x, max_speed * direction, ACCEL)
		elif can_jump:
			velocity.x = move_toward(velocity.x, 0, DECEL)

	if direction == -sign(velocity.x) and not skidding and direction != 0:
		skidding = true
		do_skid_smoke()
		if p_meter > 5 and is_on_floor():
			$Sounds.stream = preload("res://audio/player/skid.ogg")
			$Sounds.play()
	
	velocity.y = min(velocity.y + (LONG_JUMP_GRAVITY if long_jump else GRAVITY), MAX_FALL_SPEED)
	
	if Input.is_action_just_pressed("player_jump") and can_jump:
		long_jump = true;
		if not running and velocity.y < WALK_SPEED:
			velocity.y = -IDLE_JUMP_SPEED
		elif (
			(not running and velocity.y >= WALK_SPEED)
			or (running and velocity.y < RUN_SPEED)
		):
			velocity.y = -SLOW_JUMP_SPEED
		elif running and velocity.y >= RUN_SPEED:
			velocity.y = -FAST_JUMP_SPEED
		$Sounds.stream = preload("res://audio/player/jump.ogg")
		$Sounds.play()
	
	if long_jump and (velocity.y > -60 or not Input.is_action_pressed("player_jump")):
		long_jump = false
	
	if velocity.x == 0 or is_on_wall():
		$Sprite.play("idle")
		$Sprite.speed_scale = 1
	else:
		if p_meter > 5:
			$Sprite.play("run")
		else:
			$Sprite.play("walk")
		$Sprite.speed_scale = abs(velocity.x) * 12 * delta
		if direction == -1:
			$Sprite.flip_h = true
		elif direction == 1:
			$Sprite.flip_h = false
	
	if not can_jump:
		if p_meter > 5:
			$Sprite.play("p_jump")
		else:
			if velocity.y < 0:
				$Sprite.play("jump")
			elif velocity.y > 0:
				$Sprite.play("fall")
	
	if Input.is_action_pressed("player_down"):
		$Sprite.play("duck")
	
	if skidding and is_on_floor() and p_meter > 5:
		$Sprite.play("skid")
	
	# P-Meter Logic
	do_p_meter(delta)
	
	#adaprint("%.2f" % (velocity.x * delta))
	#print("%.2f" % (velocity.y * delta))

func _process(_delta: float) -> void:
	$Sprite.position = Vector2(-fmod(position.x, 1), -fmod(position.y, 1) - 15)
	$Camera2D.position = Vector2(-fmod(position.x, 1), -fmod(position.y, 1))

func do_skid_smoke() -> void:
	if skidding and is_on_floor() and p_meter > 5:
		var smoke = preload("res://scenes/particles/skid_smoke.tscn").instantiate()
		smoke.position = position.floor()
		get_tree().get_first_node_in_group("map").add_child(smoke)
		get_tree().get_first_node_in_group("map").move_child(smoke, 0)
		get_tree().create_timer(0.1).timeout.connect(do_skid_smoke)

## Responsible for all P-Meter logic.
func do_p_meter(_delta: float) -> void:
	if p_timer_enabled and abs(velocity.x) <= WALK_SPEED and p_meter == 0:
		p_timer_enabled = false
	
	if not p_timer_enabled and (abs(velocity.x) > WALK_SPEED or (abs(velocity.x) <= WALK_SPEED and p_meter != 0)):
		p_timer_enabled = true
	
	if abs(velocity.x) > WALK_SPEED or not is_on_floor():
		if p_timer > 8:
			p_timer = 0
		if (p_meter <= 5 and p_timer == 8 and is_on_floor()) or (p_meter == 6 and p_timer == 7):
			p_timer = 0
			p_meter += 1
		elif p_meter == 7 and p_timer == 7:
			p_timer = 0
			p_meter -= 1
	
	if abs(velocity.x) <= WALK_SPEED and is_on_floor():
		if p_meter > 5:
			p_meter = 5
		if p_timer == 24:
			p_timer = 0
			p_meter -= 1
	
	if p_timer_enabled:
		p_timer += 1
	
	#print(str(p_meter) + " | " + str(p_timer))

func _just_collided(collision: KinematicCollision2D) -> void:
	if collision.get_normal().y == 1:
		$Sounds.stream = preload("res://audio/player/bump.ogg")
		$Sounds.play()
