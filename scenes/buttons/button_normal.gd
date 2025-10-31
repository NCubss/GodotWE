extends TextureButton

@export var action_name: StringName = &"player_jump"  # cambia a la acción que necesites

var dragging := false
var drag_offset := Vector2.ZERO
var _last_edit_state := false
var _holding := false   # true mientras el botón esté presionado (mouse/touch)

func _ready() -> void:
	toggle_mode = false              # NO toggle
	_last_edit_state = Global.edit_mode
	_apply_edit_mode(_last_edit_state)

	# Señales propias del botón
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	focus_mode = Control.FOCUS_NONE

func _process(_dt: float) -> void:
	# Cambio de modo edición ↔ normal
	if Global.edit_mode != _last_edit_state:
		_last_edit_state = Global.edit_mode
		_apply_edit_mode(_last_edit_state)

	# Si estamos en modo normal y el botón está sostenido, mantener la acción "down"
	if not Global.edit_mode and _holding:
		# Importante: se debe llamar cada frame para mantener la acción activa
		Input.action_press(action_name)

func _apply_edit_mode(editing: bool) -> void:
	if editing:
		# En edición: sin estados visuales de "pressed"
		button_pressed = false
		# Si se entró a edición mientras estaba presionado, soltar la acción
		if _holding:
			_holding = false
			Input.action_release(action_name)
	else:
		pass

# ----- Entrada de GUI: arrastre en modo edición -----
func _gui_input(event: InputEvent) -> void:
	if Global.edit_mode:
		# Arrastrar con mouse
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
		elif (event is InputEventMouseButton and not event.pressed) \
			or (event is InputEventScreenTouch and not event.pressed):
			dragging = false
			button_pressed = false
			accept_event()
	# En modo normal, deja que TextureButton maneje su input
	# (dispara button_down / button_up)

# ----- Señales del botón (modo normal) -----
func _on_button_down() -> void:
	if Global.edit_mode:
		return
	_holding = true  # empezamos a mantener la acción "down"

func _on_button_up() -> void:
	if not _holding:
		return
	_holding = false
	Input.action_release(action_name)  # al soltar, liberar la acción

# Seguridad extra: si el dedo/mouse se va fuera del botón y "cancela", liberar
func _unhandled_input(event: InputEvent) -> void:
	if Global.edit_mode:
		return

	# Si es touch y se levantó cualquiera de los dedos, y estábamos sosteniendo, soltar
	if event is InputEventScreenTouch and not event.pressed and _holding:
		_holding = false
		Input.action_release(action_name)

	# Si es mouse y se soltó el botón, y estábamos sosteniendo, soltar
	if event is InputEventMouseButton and not event.pressed and _holding:
		_holding = false
		Input.action_release(action_name)
