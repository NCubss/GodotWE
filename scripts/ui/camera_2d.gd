extends Camera2D

## The target body to track. Defaults to the `player` group.
@export var target: CharacterBody2D = null
@export var top_margin_pixels: float = 313.0
@export var max_time: float = 0.5
@export var camera_lift: float = 40.0
@export var camera_lift_speed: float = 1.5
@export_flags_2d_physics var floor_layer_mask: int = 1
# deja un poco más de cielo por encima del bloque más alto
@export var top_padding_pixels: float = 0.0

var _time_left: float
var _finished := false
var _lifting := false
var _extra_y_offset: float = 0.0
var _max_floor_y: float = INF

func _ready() -> void:
	_time_left = max_time
	# Calcula el bloque más alto (menor Y) de todo lo que esté en
	# floor_layer_mask.
	var highest_y := INF
	var scene_root := get_tree().current_scene
	if scene_root == null:
		_max_floor_y = INF
		return
	for n in Utility.id("map").get_children():
		# Usamos su posición global como aproximación de su “techo”.
		if n.global_position.y < highest_y:
			highest_y = n.global_position.y
	_max_floor_y = highest_y
	
	if target == null:
		target = Utility.id("player")
	

func _process(delta: float) -> void:
	if target == null:
		return

	# --- DETECCIÓN ---
	var screen_center: Vector2 = get_screen_center_position()
	var vp_h: float = get_viewport_rect().size.y
	var half_h_world: float = (vp_h * 0.5) * zoom.y
	var top_edge_world_y: float = screen_center.y - half_h_world
	var trigger_world_y: float = top_edge_world_y + top_margin_pixels * zoom.y

	var in_position := target.global_position.y <= trigger_world_y
	var on_ground := target.is_on_floor()
	var should_count := in_position and on_ground

	# --- CONTADOR ---
	if should_count and not _lifting:
		if not _finished:
			_time_left -= delta
			if _time_left <= 0.0:
				_time_left = 0.0
				_finished = true
				_lifting = true
	elif not in_position and not _lifting:
		if (_time_left != max_time) or _finished:
			_time_left = max_time
			_finished = false

	# --- MOVIMIENTO DE CÁMARA ---
	var target_offset := 0.0
	if _lifting:
		target_offset = -camera_lift
		if abs(_extra_y_offset - target_offset) < 1.0 and not in_position:
			_lifting = false
			_finished = false
			_time_left = max_time
	_extra_y_offset = lerp(_extra_y_offset, target_offset,
			delta * camera_lift_speed)

	# --- SEGUIMIENTO + LÍMITE SUPERIOR ---
	var new_y = target.global_position.y + _extra_y_offset

	var top_limit := _max_floor_y
	if top_limit != INF:
		# Permite subir un poco más que el bloque más alto (más cielo):
		top_limit -= top_padding_pixels * zoom.y
		if new_y < top_limit:
			new_y = top_limit

	global_position = Vector2(target.global_position.x, new_y)
	# queue_redraw is only necessary when _draw() is involved
	#queue_redraw()
