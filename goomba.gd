extends Entity

@export var move_speed: float = 30.0
@export var player_ref: Node = null  # Se auto-buscará si no se asigna

@onready var gravity_component: Node = $GravityComponent
@onready var derecha: RayCast2D = $derecha
@onready var izquierda: RayCast2D = $izquierda
@onready var sprite: AnimatedSprite2D = $graficos/sprite
@onready var ray_derecha: RayCast2D = $killerzone/ray_derecha
@onready var ray_izquierda: RayCast2D = $killerzone/ray_izquierda
@onready var ray_up: RayCast2D = $killerzone/ray_up
@onready var killerzone: Area2D = $killerzone
@onready var pickup_component: PickupComponent = $PickupComponent   # componente de agarre

const PFX_SPIN_THUMP := preload("res://scenes/particles/spin_thump.tscn")
const SFX_KLOCK := preload("res://audio/player/klock.ogg")
const SFX_JUMP := preload("res://audio/player/jump.ogg")

var first_fall_done: bool = false
var direction: int = -1
var lastimado: bool = false
var levantarse: bool = false
var cargado: bool = false

# Volteo visual
@export var flip_cooldown_normal: float = 0.12
@export var flip_cooldown_trapped: float = 0.45
var _flip_timer: float = 0.0
var _visual_flip_h: bool = true

# Estado lastimado
@export var hurt_jump_speed: float = 70.0
@export var hurt_move_speed: float = 140.0
@export var floor_stop_friction: float = 1600.0
@export var hurt_jump_cooldown: float = 0.25
var _hurt_cd: float = 0.0

# Anti-múltiples pateos
var _last_kick_marker: Node2D = null
func _can_kick_again() -> bool:
	return _last_kick_marker == null \
		or not is_instance_valid(_last_kick_marker) \
		or not _last_kick_marker.is_inside_tree()
func _clear_kick_marker() -> void:
	_last_kick_marker = null

# ---------- util para alternar estado de “cargado” ----------
# Cambia colisiones con piso y snap apropiadamente.
func _set_carried_state(on: bool) -> void:
	cargado = on
	# Supone que el PISO está en la capa 1 (mask bit 1)
	set_collision_mask_value(1, not on)     # off si cargado, on si libre
	# Opcional: si no quieres que OTROS te detecten mientras te cargan,
	# también podrías apagar tu collision_layer bit correspondiente aquí.
	# set_collision_layer_value(1, not on)

	# Snap al piso: 0 cuando cargado, restaura cuando libre
	floor_snap_length = 0.0 if on else 8.0

	if on:
		velocity = Vector2.ZERO
		if sprite:
			sprite.rotation_degrees = 0
	else:
		# Empujoncito hacia abajo para forzar reacquisición de piso
		velocity.y = max(velocity.y, 8.0)

func _ready() -> void:
	# Buscar player si no se asignó
	if player_ref == null:
		var found_player = get_tree().get_first_node_in_group("player")
		if found_player:
			player_ref = found_player

	_visual_flip_h = direction != 1
	if sprite:
		sprite.flip_h = _visual_flip_h

	# Señales del área de stomp / daño
	if killerzone:
		killerzone.body_entered.connect(_on_killerzone_body_entered)
		killerzone.body_exited.connect(_on_killerzone_body_exited)

	# Configurar PickupComponent
	if pickup_component:
		# Bloqueado al inicio: sólo se activa cuando lastimado == true
		if "enable_pickup" in pickup_component:
			pickup_component.enable_pickup = false
		pickup_component.picked_up.connect(_on_picked)
		pickup_component.dropped.connect(_on_dropped)

	# Valor por defecto para que se pegue al piso cuando no está cargado
	floor_snap_length = 8.0

func _physics_process(delta: float) -> void:
	_hurt_cd = max(_hurt_cd - delta, 0.0)

	# Estado cargado: no detectar piso ni moverse/ser pateado
	if pickup_component and pickup_component.held:
		_set_carried_state(true)
		move_and_slide()
		return
	else:
		# Si el componente dice que ya no está held, asegúrate de restaurar
		if cargado:
			_set_carried_state(false)

	# =================== LÓGICA NORMAL ===================
	if not lastimado:
		if not first_fall_done and is_on_floor():
			first_fall_done = true

		var col_r: bool = derecha.is_colliding()
		var col_l: bool = izquierda.is_colliding()

		if col_r and not col_l:
			direction = -1
		elif col_l and not col_r:
			direction = 1

		if first_fall_done:
			velocity.x = move_speed * direction
		else:
			velocity.x = 0.0

		move_and_slide()

		_flip_timer = max(_flip_timer - delta, 0.0)
		var desired_flip_h: bool = direction != 1
		var trapped: bool = col_r and col_l
		var min_cooldown: float = flip_cooldown_trapped if trapped else flip_cooldown_normal

		if desired_flip_h != _visual_flip_h and _flip_timer <= 0.0:
			_visual_flip_h = desired_flip_h
			if sprite:
				sprite.flip_h = _visual_flip_h
			_flip_timer = min_cooldown
		else:
			if sprite:
				sprite.flip_h = _visual_flip_h

	else:
		# --- Lógica cuando está lastimado ---
		if sprite:
			sprite.rotation_degrees = 180

		var hit_r: bool = ray_derecha.is_colliding()
		var hit_l: bool = ray_izquierda.is_colliding()
		var hit_up: bool = ray_up.is_colliding()

		# Si pega con techo, moverse lento horizontal
		hurt_move_speed = 30.0 if hit_up else 140.0

		# En piso: frena fuerte para que no resbale
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, floor_stop_friction * delta)

			# Si está siendo cargado NO se patea (doble verificación)
			var puede_patear := not (pickup_component and pickup_component.held)

			# Ray derecho -> salto a la izquierda
			if puede_patear and hit_r and _hurt_cd <= 0.0 and _can_kick_again():
				var spin_thump := PFX_SPIN_THUMP.instantiate()
				_last_kick_marker = spin_thump
				spin_thump.tree_exited.connect(_clear_kick_marker)
				call_deferred("add_sibling", spin_thump)
				spin_thump.global_position = global_position

				if player_ref and "sounds" in player_ref and player_ref.sounds:
					player_ref.sounds.stream = SFX_KLOCK
					player_ref.sounds.play()

				velocity.y = -hurt_jump_speed
				velocity.x = -hurt_move_speed
				_visual_flip_h = true
				if sprite:
					sprite.flip_h = _visual_flip_h
				_hurt_cd = hurt_jump_cooldown

			# Ray izquierdo -> salto a la derecha
			if puede_patear and hit_l and _hurt_cd <= 0.0 and _can_kick_again():
				var spin_thump2 := PFX_SPIN_THUMP.instantiate()
				_last_kick_marker = spin_thump2
				spin_thump2.tree_exited.connect(_clear_kick_marker)
				call_deferred("add_sibling", spin_thump2)
				spin_thump2.global_position = global_position

				if player_ref and "sounds" in player_ref and player_ref.sounds:
					player_ref.sounds.stream = SFX_KLOCK
					player_ref.sounds.play()

				velocity.y = -hurt_jump_speed
				velocity.x = hurt_move_speed
				_visual_flip_h = false
				if sprite:
					sprite.flip_h = _visual_flip_h
				_hurt_cd = hurt_jump_cooldown

		move_and_slide()

# ==================== DETECCIÓN KILLERZONE (sin agarre) ====================
func _on_killerzone_body_entered(body: Node2D) -> void:
	if body is Player:
		var player: Player = body as Player

		# Stomp / daño desde arriba
		if player.velocity.y > 0.0 and not player.is_on_floor():
			var bounce: float = player.stomp_bounce_speed

			if not lastimado and not player.is_spinning:
				if Input.is_action_pressed("player_jump"):
					bounce += 40.0

				player.has_pending_jump = true
				player.pending_jump_speed = bounce

				if "sounds" in player and player.sounds:
					player.sounds.stream = SFX_JUMP
					player.sounds.play()

				player.state_machine.transition_to(PlayerJumpingState)

				var spin_thump := PFX_SPIN_THUMP.instantiate()
				call_deferred("add_sibling", spin_thump)
				spin_thump.global_position = player.global_position

				if "sounds" in player and player.sounds:
					player.sounds.stream = SFX_KLOCK
					player.sounds.play()

				# Al volverse lastimado, ahora SÍ se puede recoger
				lastimado = true
				if pickup_component and "enable_pickup" in pickup_component:
					pickup_component.enable_pickup = true

			elif player.is_spinning:
				queue_free()
				player.pending_jump_speed = bounce
				player.has_pending_jump = true
				if Input.is_action_pressed("player_spin_jump"):
					bounce += 40.0
				player.state_machine.transition_to(PlayerSpinJumpingState)

func _on_killerzone_body_exited(_body: Node2D) -> void:
	pass

# ==================== Señales del PickupComponent ====================
func _on_picked(holder: Node) -> void:
	_set_carried_state(true)

func _on_dropped(_holder: Node) -> void:
	_set_carried_state(false)
