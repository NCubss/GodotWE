@abstract
class_name State
extends Node
## Represents a specific behavior for an entity, used in a [StateMachine].
## 
## States come with a few virtual function clones (e.g. [method Node._process],
## [method Node._physics_process]), which will be called by the
## [StateMachine]. These functions return what the next [State] is going to be.
## To not switch state, [code]null[/code] should be returned. See an example:
## [codeblock]
## class_name ExampleState
## extends State
## 
## func physics_process(entity: Node2D, delta: float) -> Variant:
##     if should_switch_state:
##         # Return the class, not a new instance!
##         return NewState
##     else:
##         # Don't switch state
##         return null
## [/codeblock]
## If the state isn't found in the [StateMachine], it will throw an error.

## The class this state is designed for. The state machine will raise an error
## if this class does not match the node this state is applied to.
var intended_class: Variant = Node2D

## The node the state is interacting with (i.e. the parent of the
## [StateMachine]). This is set before [method start] is called.
var node: Node


## Runs once the state has just been enabled.
@warning_ignore("unused_parameter")
func start() -> Script:
	return null


## Runs once the state is just about to stop in favor of a new state. You cannot
## return a different state to switch to in this function, as the next state is
## already selected.
@warning_ignore("unused_parameter")
func end() -> void:
	pass


## Runs every frame. Clone of [method Node._process].
@warning_ignore("unused_parameter")
func process(delta: float) -> Script:
	return null


## Runs every physics tick. Clone of [method Node._physics_process].
@warning_ignore("unused_parameter")
func physics_process(delta: float) -> Script:
	return null


## Runs when an input event is received. Clone of [method Node._input].
@warning_ignore("unused_parameter")
func input(event: InputEvent) -> Script:
	return null
