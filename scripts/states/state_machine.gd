class_name StateMachine
extends Node
## Manages switching between multiple [State]s.
## The owner of this node is passed to states as the 'entity' (e.g., Player).

## The current state (must be a child node that extends State)
@export var current_state: State


func _ready() -> void:
	# If a state is already assigned in the inspector, start it.
	if current_state != null:
		current_state.start(owner)


func _process(delta: float) -> void:
	_state_stuff(current_state.process.bind(owner, delta))


func _physics_process(delta: float) -> void:
	_state_stuff(current_state.physics_process.bind(owner, delta))


func _state_stuff(function: Callable) -> void:
	if current_state == null:
		return
	var new_state: Variant = function.call()

	if new_state == null:
		return
	# new_state must be a class reference of a child State (e.g., PlayerJumpingState)
	_transition_internal(new_state)


## Public API to switch state from outside (e.g., enemy or player code):
func transition_to(new_state: Variant) -> void:
	if new_state == null:
		return
	_transition_internal(new_state)


## Alias, por si prefieres este nombre:
func set_state(new_state: Variant) -> void:
	transition_to(new_state)


func _transition_internal(new_state: Variant) -> void:
	if current_state != null:
		current_state.end(owner)

	# Look for a child State node whose script class matches 'new_state'
	current_state = Utility.find_child_by_class(self, new_state)
	assert(current_state != null, "Expected a valid state, got null. Did you add the State as a child and export class_name?")

	current_state.start(owner)
