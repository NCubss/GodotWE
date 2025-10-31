extends TextureButton

@export var action_name: StringName = &"player_run"

var dragging := false
var drag_offset := Vector2.ZERO
var _tex_normal_orig: Texture2D
var _last_edit_state := false
var _pointer_down := false                 # ¿hay dedo/click sostenido sobre el botón?
var _effective_on_prev := false            # estado efectivo del frame anterior (para soltar una sola vez)

func _ready() -> void:
	toggle_mode = false
	_tex_normal_orig = texture_normal

	_last_edit_state = Global.edit_mode
	_apply_edit_mode(_last_edit_state)

	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	focus_mode = Control.FOCUS_NONE
	button_pressed = false

func _process(_dt: float) -> void:
	# Detecta cambio a/desde modo edición
	if Global.edit_mode != _last_edit_state:
		_last_edit_state = Global.edit_mode
		_apply_edit_mode(_last_edit_state)

	# ---- Estado efectivo: activo si NO estamos en edición y (hay dedo o la global pide ON) ----
	var effective_on := (not Global.edit_mode) and (_pointer_down or Global.button_run)

	# 1) INPUT continuo por frame
	if effective_on:
		Input.action_press(action_name)          # mantener la acción viva
	elif _effective_on_prev:
		Input.action_release(action_name)        # soltar una sola vez en el flanco de bajada

	# 2) Visual (swap de textura sin quedarse hundido)
	if effective_on and texture_pressed:
		texture_normal = texture_pressed
	else:
		if _tex_normal_orig:
			texture_normal = _tex_normal_orig
	button_pressed = false

	_effective_on_prev = effective_on

func _apply_edit_mode(editing: bool) -> void:
	if editing:
		# Si entramos a edición y estaba activo, soltar y limpiar
		if _effective_on_prev:
			Input.action_release(action_name)
		_pointer_down = false
		_effective_on_prev = false
		button_pressed = false
		if _tex_normal_orig:
			texture_normal = _tex_normal_orig
	else:
		# Salimos de edición: no hay nada más que hacer, el estado se reevaluará en _process
		pass

# ----- Señales del botón -----
func _on_button_down() -> void:
	if Global.edit_mode:
		return
	_pointer_down = true

func _on_button_up() -> void:
	_pointer_down = false
	# La liberación real la maneja _process con el flanco de bajada del estado efectivo

# Seguridad extra: si la pulsación se “cancela” fuera del botón
func _unhandled_input(event: InputEvent) -> void:
	if Global.edit_mode:
		return

	if event is InputEventScreenTouch and not event.pressed and _pointer_down:
		_pointer_down = false
	if event is InputEventMouseButton and not event.pressed and _pointer_down:
		_pointer_down = false
	# El release se hará en _process cuando effective_on pase a false

# ----- MODO EDICIÓN: arrastre sin accionar -----
func _gui_input(event: InputEvent) -> void:
	if Global.edit_mode:
		if event is InputEventMouseButton and event.pressed:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
			button_pressed = false
			accept_event()
		elif event is InputEventScreenTouch and event.pressed:
			dragging = true
			drag_offset = event.position - global_position
			button_pressed = false
			accept_event()
		elif event is InputEventMouseMotion and dragging:
			global_position = get_global_mouse_position() - drag_offset
			accept_event()
		elif event is InputEventScreenDrag and dragging:
			global_position = event.position - drag_offset
			accept_event()
		elif (event is InputEventMouseButton and not event.pressed) or (event is InputEventScreenTouch and not event.pressed):
			dragging = false
			button_pressed = false
			accept_event()
