@icon("uid://qt8g8w6w8xwp")
class_name StateMachine
extends Node
## Manages switching between multiple [State]s.
## 
## See [State] for more information.

## The current state.
@export var current_state: State


func _init() -> void:
	child_entered_tree.connect(_child_entered_tree)


func _enter_tree() -> void:
	if is_node_ready():
		return
	await ready
	if current_state != null:
		current_state.node = get_parent()
	_call_and_switch("start")


func _process(delta: float) -> void:
	_call_and_switch("process", delta)


func _physics_process(delta: float) -> void:
	_call_and_switch("physics_process", delta)


func _input(event: InputEvent) -> void:
	_call_and_switch("input", event)


## Forcibly changes the state machine's current state.
func switch(state_type: Script) -> void:
	if current_state != null:
		if current_state.get_script() == state_type:
			return
		current_state.end()
	var state = Utility.find_child_by_class(self, state_type)
	assert(state != null, "State machine does not have %s"
			% state_type.get_global_name())
	current_state = state
	state.node = get_parent()
	_call_and_switch("start")


func _call_and_switch(method: StringName, ...args: Array) -> void:
	if current_state == null:
		return
	var new_state: Script = Callable(current_state, method).callv(args)
	if new_state == null or current_state.get_script() == new_state:
		return
	
	current_state.end()
	current_state = Utility.find_child_by_class(self, new_state)
	assert(current_state != null, "No %s in state machine"
			% new_state.get_global_name())
	current_state.node = get_parent()
	
	_call_and_switch("start")


func _child_entered_tree(node: Node) -> void:
	var state = node as State
	if state == null:
		return
	assert(is_instance_of(get_parent(), state.intended_class),
			"%s will not work with %s" % [state.get_script().get_global_name(),
			get_parent().name])
