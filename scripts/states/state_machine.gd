class_name StateMachine
extends Node
## Manages switching between multiple [State]s.
## 
## See [State] for more information.

## The current state.
@export var current_state: State


func _process(delta: float) -> void:
	_state_stuff(current_state.process.bind(owner, delta))


func _physics_process(delta: float) -> void:
	_state_stuff(current_state.physics_process.bind(owner, delta))


func _state_stuff(function: Callable) -> void:
	if current_state == null:
		return
	var new_state = function.call()
	if new_state == null:
		return
	current_state.end(owner)
	current_state = Utility.find_child_by_class(self, new_state)
	assert(current_state != null, "Expected a valid state, got null")
	current_state.start(owner)
