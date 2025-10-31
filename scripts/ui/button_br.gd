extends TextureButton

@export var action_name: StringName = &"player_run"

var dragging := false
var drag_offset := Vector2.ZERO
var _prev_toggle := true
var _last_edit_state := false

func _ready():
	toggle_mode = true
	_last_edit_state = Global.edit_mode
	_apply_edit_mode(Global.edit_mode)



func _apply_edit_mode(editing: bool) -> void:
	if editing:
		# Guarda el estado y desactiva el toggle (para que no cambie sprite ni estado)
		_prev_toggle = toggle_mode
		toggle_mode = false
		if button_pressed:
			button_pressed = false
		modulate.a = 0.8  # más transparente para indicar modo edición
	else:
		# Restaura el comportamiento normal
		toggle_mode = _prev_toggle
		modulate.a = 1.0

func _gui_input(event):
	if Global.edit_mode:
		# ----- MODO EDICIÓN: se puede mover -----
		if event is InputEventMouseButton or event is InputEventScreenTouch:
			if event.pressed:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
				button_pressed = false
				accept_event()
			else:
				dragging = false
				button_pressed = false
				accept_event()
		elif event is InputEventMouseMotion and dragging:
			global_position = get_global_mouse_position() - drag_offset
			accept_event()
	else:
		# ----- MODO NORMAL: comportamiento normal del botón -----
		pass

func _toggled(button_pressed: bool) -> void:
	# Solo actuar si NO estamos en modo edición
	if Global.edit_mode:
		return
	if button_pressed:
		Input.action_press(action_name)
		Global.button_run = true
	else:
		Global.button_run = false
		Input.action_release(action_name)
