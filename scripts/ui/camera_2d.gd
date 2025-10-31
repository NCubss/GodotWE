extends Camera2D

@export var target: CharacterBody2D
@export var top_margin_pixels: float = 313.0
@export var max_time: float = 0.5
@export var camera_lift: float = 40.0
@export var camera_lift_speed: float = 1.5
@export_flags_2d_physics var floor_layer_mask: int = 1
@export var top_padding_pixels: float = 0.0  # deja un poco más de cielo por encima del bloque más alto

var time_left: float
var _was_inside := false
var _finished := false
var _lifting := false
var extra_y_offset: float = 0.0
var max_floor_y: float = INF

func _ready() -> void:
	time_left = max_time
	_update_floor_limit()

# --- Helper: recorre todo el árbol y junta nodos con colisión en la layer dada ---
func _gather_floor_nodes(root: Node, layer_mask: int) -> Array:
	var out: Array = []
	if root is TileMap:
		var tm := root as TileMap
		if (tm.collision_layer & layer_mask) != 0:
			out.append(tm)
	elif root is CollisionObject2D and not (root is TileMap):
		var co := root as CollisionObject2D
		if (co.collision_layer & layer_mask) != 0:
			out.append(co)
	for c in root.get_children():
		out.append_array(_gather_floor_nodes(c, layer_mask))
	return out

# Calcula el bloque más alto (menor Y) de todo lo que esté en floor_layer_mask.
func _update_floor_limit() -> void:
	var highest_y := INF
	var scene_root := get_tree().current_scene
	if scene_root == null:
		max_floor_y = INF
		return

	var floors := _gather_floor_nodes(scene_root, floor_layer_mask)

	# 1) TileMaps
	for n in floors:
		if n is TileMap:
			var tm: TileMap = n
			var used_rect := tm.get_used_rect()
			if used_rect.size.y == 0:
				continue
			# fila superior (menor y en coords de mapa)
			var top_row := used_rect.position.y
			var left_col := used_rect.position.x
			# Convertimos una celda de esa fila a mundo (cualquier x de la fila sirve)
			var local_at_top := tm.map_to_local(Vector2i(left_col, top_row))
			var world_at_top := tm.to_global(local_at_top)
			if world_at_top.y < highest_y:
				highest_y = world_at_top.y

	# 2) Otros cuerpos con colisión (StaticBody2D, etc.)
	for n in floors:
		if n is CollisionObject2D and not (n is TileMap):
			var co: CollisionObject2D = n
			# Usamos su posición global como aproximación de su “techo”.
			if co.global_position.y < highest_y:
				highest_y = co.global_position.y

	max_floor_y = highest_y

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
			time_left -= delta
			if time_left <= 0.0:
				time_left = 0.0
				_finished = true
				_lifting = true
	elif not in_position and not _lifting:
		if (time_left != max_time) or _finished:
			time_left = max_time
			_finished = false

	# --- MOVIMIENTO DE CÁMARA ---
	var target_offset := 0.0
	if _lifting:
		target_offset = -camera_lift
		if abs(extra_y_offset - target_offset) < 1.0 and not in_position:
			_lifting = false
			_finished = false
			time_left = max_time
	extra_y_offset = lerp(extra_y_offset, target_offset, delta * camera_lift_speed)

	# --- SEGUIMIENTO + LÍMITE SUPERIOR ---
	var new_y = target.global_position.y + extra_y_offset

	var top_limit := max_floor_y
	if top_limit != INF:
		# Permite subir un poco más que el bloque más alto (más cielo):
		top_limit -= top_padding_pixels * zoom.y
		if new_y < top_limit:
			new_y = top_limit

	global_position = Vector2(target.global_position.x, new_y)
	queue_redraw()
