@icon("uid://dkksfwlo1l87c")
class_name Sprout
extends Resource
## Responsible for ejecting an item from a container with a [BlockComponent].

## This sprout's container. Can be either [CharacterBodyExt] or [StaticBodyExt].
var body: PhysicsBody2D
## Whether this sprout is done sprouting and the containing block should
## continue.
var empty := false


## Called when the container has just been activated. For example, coins
## typically sprout at this time. [param position] and [param direction] are
## the position on the container's edge and the direction as a normal for how
## the sprouting should happen, respectively.
@warning_ignore("unused_parameter")
func start_sprout(position: Vector2, direction: Vector2) -> void:
	return


## Called when the container is finishing activation. All items that rise from
## the container typically sprout at this time. See [method start_sprout].
@warning_ignore("unused_parameter")
func end_sprout(position: Vector2, direction: Vector2) -> void:
	return
