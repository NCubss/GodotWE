class_name ControlSet
extends Control
## A control set.
## 
## This class only manages the [code]player_run_toggle[/code] action, so, once
## it is pressed, [code]player_run[code] will also be pressed.


var _toggle_state := false


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("player_run_toggle"):
		return
	_toggle_state = !_toggle_state
	var new_event = InputEventAction.new()
	new_event.action = "player_run"
	new_event.pressed = _toggle_state
	Input.parse_input_event(new_event)
