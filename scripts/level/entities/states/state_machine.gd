@icon("uid://qt8g8w6w8xwp")
class_name StateMachine
extends Node
## Manages switching between multiple [State]s.
## 
## See [State] for more information.

## The current state.
@export var current_state: State


## Forcibly changes the state machine's current state.
func switch(state_type: Variant) -> void:
	current_state.end(get_parent())
	var state = Utility.find_child_by_class(self, state_type)
	assert(state != null, "State machine does not have this state.")
	current_state = state
	current_state.start(get_parent())


func _process(delta: float) -> void:
	_state_stuff(current_state.process.bind(get_parent(), delta))


func _physics_process(delta: float) -> void:
	_state_stuff(current_state.physics_process.bind(get_parent(), delta))


func _input(event: InputEvent) -> void:
	_state_stuff(current_state.input.bind(get_parent(), event))


func _state_stuff(function: Callable) -> void:
	if current_state == null:
		return
	var new_state = function.call()
	if new_state == null:
		return
	current_state.end(get_parent())
	current_state = Utility.find_child_by_class(self, new_state)
	assert(current_state != null, "Expected a valid state, got null")
	current_state.start(get_parent())
