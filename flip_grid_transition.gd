extends CanvasLayer
class_name FlipGridTransition

@export var rows: int = 1600
@export var cols: int = 1600
@export var tile_delay: float = 0.03
@export var tile_duration: float = 0.35
@export var auto_play_on_ready: bool = true  # 🔹 nuevo

signal finished

@onready var _rect: ColorRect = $ColorRect
@onready var _mat: ShaderMaterial = _rect.material

var _t := 0.0
var _total_time := 0.0
var _running := false

func _ready() -> void:
	visible = false
	_mat.set_shader_parameter("rows", rows)
	_mat.set_shader_parameter("cols", cols)
	_mat.set_shader_parameter("tile_delay", tile_delay)
	_mat.set_shader_parameter("tile_duration", tile_duration)

	# 🔹 Si auto_play_on_ready está activado, corre la animación sola
	if auto_play_on_ready:
		await get_tree().process_frame
		await play_only()

func _process(delta: float) -> void:
	if not _running:
		return
	_t += delta
	_mat.set_shader_parameter("progress_sec", _t)
	if _t >= _total_time:
		_running = false
		visible = false
		emit_signal("finished")

func _compute_total_time() -> float:
	var last_start := float((rows - 1) + (cols - 1)) * tile_delay
	return last_start + tile_duration

func _snapshot_from_tex() -> Texture2D:
	await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	return ImageTexture.create_from_image(img)

func play_only() -> void:
	var from_tex := await _snapshot_from_tex()
	_start(from_tex)

func play_and_change(change_scene_callable: Callable) -> void:
	var from_tex := await _snapshot_from_tex()
	change_scene_callable.call()
	await get_tree().process_frame
	_start(from_tex)

func _start(from_tex: Texture2D) -> void:
	_mat.set_shader_parameter("from_tex", from_tex)
	_mat.set_shader_parameter("rows", rows)
	_mat.set_shader_parameter("cols", cols)
	_mat.set_shader_parameter("tile_delay", tile_delay)
	_mat.set_shader_parameter("tile_duration", tile_duration)
	_t = 0.0
	_total_time = _compute_total_time()
	visible = true
	_running = true
	set_process(true)
